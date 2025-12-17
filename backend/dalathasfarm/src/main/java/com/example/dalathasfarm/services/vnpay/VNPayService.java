package com.example.dalathasfarm.services.vnpay;

import com.example.dalathasfarm.components.VNPayConfig;
import com.example.dalathasfarm.components.VNPayUtils;
import com.example.dalathasfarm.dtos.PaymentDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.repositories.OrderRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VNPayService implements IVNPayService {
    private final VNPayConfig vnPayConfig;
    private final VNPayUtils vnPayUtils;
    private final OrderRepository orderRepository;

    private boolean isMobileDevice(String userAgent) {
        // Kiem tra User-Agent header de xac dinh thiet bi di dong
        return userAgent.toLowerCase().contains("mobile");
    }

    @Override
    public String createPaymentUrl(PaymentDto paymentDto, HttpServletRequest request) {
        String version = "2.1.0";
        String command = "pay";
        String orderType = "other";
        long amount = paymentDto.getAmount() * 100;
        String bankCode = paymentDto.getBankCode();

        String transactionReference = vnPayUtils.getRandomNumber(8); // Ma giao dich
        String clientIpAddress = vnPayUtils.getIpAddress(request);

        String terminalCode = vnPayConfig.getVnpTmnCode();

        Map<String, String> params = new HashMap<>();
        params.put("vnp_Version", version);
        params.put("vnp_Command", command);
        params.put("vnp_TmnCode", terminalCode);
        params.put("vnp_Amount", String.valueOf(amount));
        params.put("vnp_CurrCode", "VND");

        if (bankCode != null && !bankCode.isEmpty()) {
            params.put("vnp_BankCode", bankCode);
        }
        params.put("vnp_TxnRef", transactionReference);
        params.put("vnp_OrderInfo", "Thanh toán đơn hàng: " + transactionReference);
        params.put("vnp_OrderType", orderType);

        String locale = paymentDto.getLanguage();
        if (locale != null && !locale.isEmpty()) {
            params.put("vnp_Locale", locale);
        } else {
            params.put("vnp_Locale", "vn");
        }

        String userAgent = request.getHeader("User-Agent");
        if (isMobileDevice(userAgent)) {
            params.put("vnp_ReturnUrl", vnPayConfig.getVnpReturnMobileUrl());
        }else {
            params.put("vnp_ReturnUrl", vnPayConfig.getVnpReturnWebUrl());
        }
        params.put("vnp_IpAddr", clientIpAddress);

        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        String createdDate = dateFormat.format(calendar.getTime());
        params.put("vnp_CreateDate", createdDate);

        calendar.add(Calendar.MINUTE, 15);
        String expirationDate = dateFormat.format(calendar.getTime());
        params.put("vnp_ExpireDate", expirationDate);

        List<String> sortedFieldNames = new ArrayList<>(params.keySet());
        Collections.sort(sortedFieldNames);

        StringBuilder hashData = new StringBuilder();
        StringBuilder queryData = new StringBuilder();

        for (Iterator<String> iterator = sortedFieldNames.iterator(); iterator.hasNext(); ) {
            String fieldName = iterator.next();
            String fieldValue = params.get(fieldName);

            if (fieldValue != null && !fieldValue.isEmpty()) {
                hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.UTF_8));
                queryData.append(URLEncoder.encode(fieldName, StandardCharsets.UTF_8))
                        .append('=')
                        .append(URLEncoder.encode(fieldValue, StandardCharsets.UTF_8));
                if (iterator.hasNext()) {
                    hashData.append('&');
                    queryData.append('&');
                }
            }
        }

        String secureHash = vnPayUtils.hmacSHA512(vnPayConfig.getSecretKey(), hashData.toString());
        queryData.append("&vnp_SecureHash=").append(secureHash);

        return vnPayConfig.getVnpPayUrl() + "?" + queryData;
    }

    @Override
    public boolean verifyCallback(Map<String, String> params) {
        String vnpSecureHash = params.remove("vnp_SecureHash");
        params.remove("vnp_SecureHashType");

        Map<String, String> sortedParams = new TreeMap<>(params);

        String hashData = sortedParams.entrySet().stream()
                .map(e -> e.getKey() + "=" + URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8))
                .collect(Collectors.joining("&"));

        String calculatedHash = hmacSHA512(vnPayConfig.getSecretKey(), hashData);

        return calculatedHash.equalsIgnoreCase(vnpSecureHash);
    }

    @Override
    @Transactional
    public void handleFailed(String txnRef, Map<String, String> params) throws Exception {
        Optional<Order> existingOrder = orderRepository.findByVnpTxnRef(txnRef);
        Order order = new Order();

        if (existingOrder.isPresent()) {
            order = existingOrder.get();
        } else throw new DataNotFoundException("Order not found");

        order.setStatus(Order.OrderStatus.Cancelled);
        orderRepository.save(order);
    }

    @Override
    @Transactional
    public void handleSuccess(String txnRef, Map<String, String> params) throws Exception {
        Optional<Order> existingOrder = orderRepository.findByVnpTxnRef(txnRef);
        Order order = new Order();

        if (existingOrder.isPresent()) {
            order = existingOrder.get();
        } else throw new DataNotFoundException("Order not found");

        if (order.getStatus() == Order.OrderStatus.Processing) return;

        order.setStatus(Order.OrderStatus.Processing);
        orderRepository.save(order);
    }

    private String hmacSHA512(String key, String data) {
    try {
        Mac mac = Mac.getInstance("HmacSHA512");
        SecretKeySpec secretKeySpec =
                new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
        mac.init(secretKeySpec);
        byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));

        StringBuilder sb = new StringBuilder(2 * rawHmac.length);
        for (byte b : rawHmac) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    } catch (Exception e) {
        throw new RuntimeException("Error while hashing", e);
    }
}

//    @Override
//    public String queryTransaction(PaymentQueryDTO paymentQueryDTO, HttpServletRequest request) throws IOException {
//        // Chuan bi tham so cho VNPay
//        String requestId = vnPayUtils.getRandomNumber(8);
//        String version = "2.1.0";
//        String command = "querydr";
//        String terminalCode = vnPayConfig.getVnpTmnCode();
//        String transactionReference = paymentQueryDTO.getOrderId();
//        String transactionDate = paymentQueryDTO.getTransDate();
//        String createDate = vnPayUtils.getCurrentDateTime();
//        String clientIpAddress = vnPayUtils.getIpAddress(request);
//
//        Map<String, String> params = new HashMap<>();
//        params.put("vnp_RequestId", requestId);
//        params.put("vnp_Version", version);
//        params.put("vnp_Command", command);
//        params.put("vnp_TmnCode", terminalCode);
//        params.put("vnp_TxnRef", transactionReference);
//        params.put("vnp_OrderInfo", "Check transaction result for OrderId:" + transactionReference);
//        params.put("vnp_TransactionDate", transactionDate);
//        params.put("vnp_CreateDate", createDate);
//        params.put("vnp_IpAddr", clientIpAddress);
//
//        // Tạo chuỗi hash và chữ ký bảo mật
//        String hashData = String.join("|", requestId, version, command,
//                terminalCode, transactionReference, transactionDate, createDate, clientIpAddress, "Check transaction");
//        String secureHash = vnPayUtils.hmacSHA512(vnPayConfig.getSecretKey(), hashData);
//        params.put("vnp_SecureHash", secureHash);
//
//        // Gửi yêu cầu API đến VNPay
//        URL apiUrl = new URL(vnPayConfig.getVnpApiUrl());
//        HttpURLConnection connection = (HttpURLConnection) apiUrl.openConnection();
//        connection.setRequestMethod("POST");
//        connection.setRequestProperty("Content-Type", "application/json");
//        connection.setDoOutput(true);
//        try (DataOutputStream writer = new DataOutputStream(connection.getOutputStream())) {
//            writer.writeBytes(new Gson().toJson(params));
//            writer.flush();
//        }
//
//        int responseCode = connection.getResponseCode();
//        try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
//            StringBuilder response = new StringBuilder();
//            String line;
//            while ((line = reader.readLine()) != null) {
//                response.append(line);
//            }
//
//            if (responseCode == 200) {
//                return response.toString();
//            } else {
//                throw new RuntimeException("VNPay API Error: " + response.toString());
//            }
//        }catch (IOException e) {
//            throw new IOException("Failed to connect to VNPay API", e);
//        } finally {
//            connection.disconnect();
//        }
//
//
//    }
//
//    @Override
//    public String refundTransaction(PaymentRefundDTO paymentRefundDTO) throws IOException {
//        String requestId = vnPayUtils.getRandomNumber(8); // Unique request ID
//        String version = "2.1.0"; // API version
//        String command = "refund"; // Refund command
//        String terminalCode = vnPayConfig.getVnpTmnCode(); // Terminal code
//
//        // Build VNPay parameters
//        Map<String, String> params = new LinkedHashMap<>();
//        params.put("vnp_RequestId", requestId);
//        params.put("vnp_Version", version);
//        params.put("vnp_Command", command);
//        params.put("vnp_TmnCode", terminalCode);
//        params.put("vnp_TransactionType", paymentRefundDTO.getTransactionType());
//        params.put("vnp_TxnRef", paymentRefundDTO.getOrderId());
//        BigDecimal amount = paymentRefundDTO.getAmount().multiply(BigDecimal.valueOf(100));
//        params.put("vnp_Amount", amount.toPlainString()); // Đảm bảo không có ký hiệu khoa học
//        params.put("vnp_OrderInfo", "Refund for OrderId: " + paymentRefundDTO.getOrderId());
//        params.put("vnp_TransactionDate", paymentRefundDTO.getTransactionDate());
//        params.put("vnp_CreateBy", paymentRefundDTO.getCreatedBy());
//        params.put("vnp_IpAddr", paymentRefundDTO.getIpAddress());
//
//        // Generate secure hash
//        String hashData = String.join("|",
//                requestId,
//                version,
//                command,
//                terminalCode,
//                paymentRefundDTO.getTransactionType(),
//                paymentRefundDTO.getOrderId(),
//                paymentRefundDTO.getAmount().multiply(BigDecimal.valueOf(100)).toPlainString(),
//                paymentRefundDTO.getTransactionDate(),
//                paymentRefundDTO.getCreatedBy(),
//                paymentRefundDTO.getIpAddress(),
//                "Refund for OrderId: " + paymentRefundDTO.getOrderId());
//        String secureHash = vnPayUtils.hmacSHA512(vnPayConfig.getSecretKey(), hashData);
//        params.put("vnp_SecureHash", secureHash);
//
//        // Send request to VNPay
//        URL apiUrl = new URL(vnPayConfig.getVnpApiUrl());
//        HttpURLConnection connection = (HttpURLConnection) apiUrl.openConnection();
//        connection.setRequestMethod("POST");
//        connection.setRequestProperty("Content-Type", "application/json");
//        connection.setDoOutput(true);
//
//        try (OutputStream outputStream = connection.getOutputStream()) {
//            byte[] jsonPayload = new ObjectMapper().writeValueAsBytes(params);
//            outputStream.write(jsonPayload, 0, jsonPayload.length);
//        }
//
//        // Read response
//        int responseCode = connection.getResponseCode();
//        if (responseCode != HttpURLConnection.HTTP_OK) {
//            throw new RuntimeException("Failed to process refund. Response code: " + responseCode);
//        }
//
//        try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
//            StringBuilder responseBuilder = new StringBuilder();
//            String line;
//            while ((line = bufferedReader.readLine()) != null) {
//                responseBuilder.append(line.trim());
//            }
//            return responseBuilder.toString();
//        }
//    }
}
