package com.example.dalathasfarm.services;

import com.example.dalathasfarm.models.*;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import org.springframework.core.io.ClassPathResource;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Locale;

public class InvoicePdfService {

    private static final NumberFormat VN_CURRENCY = NumberFormat.getInstance(new Locale("vi", "VN"));

    public static byte[] generateInvoicePdfOrder(Order order, List<OrderDetail> orderDetails) throws IOException {

        // 1. Load template HTML
        ClassPathResource resource = new ClassPathResource("templates/invoice-order.html");
        String html = new String(
                resource.getInputStream().readAllBytes(),
                StandardCharsets.UTF_8
        );

        String logoBase64 = Base64.getEncoder().encodeToString(
                Files.readAllBytes(Paths.get("uploads/images/logo.png"))
        );
        html = html.replace("{{logoImage}}", "data:image/png;base64," + logoBase64);
        // 2. Format date
        LocalDate orderDate = order.getOrderDate();
        html = html.replace("{{orderDay}}", String.format("%02d", orderDate.getDayOfMonth()));
        html = html.replace("{{orderMonth}}", String.format("%02d", orderDate.getMonthValue()));
        html = html.replace("{{orderYear}}", String.valueOf(orderDate.getYear()));

        // 3. Invoice info
        html = html.replace("{{invoiceNumber}}", String.valueOf(order.getId()));

        // 4. Company info (thay thế bằng thông tin công ty của bạn)
        html = html.replace("{{companyName}}", "CHI NHÁNH CÔNG TY TNHH DALAT HASFARM TẠI THÀNH PHỐ HỒ CHÍ MINH");
        html = html.replace("{{companyAddress}}", "56 Nơ Trang Long, Phường 14, Quận Bình Thạnh, Thành phố Hồ Chí Minh, Việt Nam");
        html = html.replace("{{companyTaxCode}}", "5800000167-001");
        html = html.replace("{{companyPhone}}", "024-37196043");
        html = html.replace("{{companyBankAccount}}", "0071001675813");
        html = html.replace("{{companyBank}}", "NGÂN HÀNG TMCP NGOẠI THƯƠNG VIỆT NAM - CHI NHÁNH LÂM ĐỒNG");

        // 5. Customer info
        html = html.replace("{{customerName}}", order.getFullName());
        html = html.replace("{{customerAddress}}",
                order.getAddress() != null ? order.getAddress() : "");
        html = html.replace("{{paymentMethod}}", order.getPaymentMethod().name());

        // 6. Build items table
        StringBuilder items = new StringBuilder();
        int index = 1;

        for (OrderDetail d : orderDetails) {
            items.append(String.format("""
                            <tr>
                               <td>%d</td>
                               <td>%s</td>
                               <td class="text-left">%s</td>
                               <td>%s</td>
                               <td style="text-align: center;">%d</td>
                               <td class="text-right">%s</td>
                               <td class="text-right">%s</td>
                            </tr>
                            """,
                    index++,
                    d.getProduct().getId(),
                    d.getProduct().getName(),
                    "CÁI", // Đơn vị tính - lấy từ Product nếu có
                    d.getQuantity(),
                    formatCurrency(d.getPrice()),
                    formatCurrency(d.getTotalMoney())
            ));
        }

        html = html.replace("{{items}}", items.toString());

        // 7. Summary amounts
        html = html.replace("{{totalAmount}}", formatCurrency(order.getTotalMoney()));

        // 8. Amount in words
        html = html.replace("{{totalAmountInWords}}",
                convertNumberToWords(order.getTotalMoney()));

        // 9. Footer info (optional)
        html = html.replace("{{lookupUrl}}", "http://localhost:4200/order-invoice");
        html = html.replace("{{lookupCode}}", order.getId().toString());

        // 10. Convert HTML -> PDF with Vietnamese font support
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.withHtmlContent(html, "/");

        // QUAN TRỌNG: Thêm font hỗ trợ tiếng Việt
        // Tải font DejaVuSans.ttf và đặt vào src/main/resources/fonts/
        try {
            builder.useFont(() -> InvoicePdfService.class.getResourceAsStream("/fonts/DejaVuSans.ttf"),
                    "DejaVu Sans");
        } catch (Exception e) {
            System.err.println("Warning: Could not load Vietnamese font. " +
                    "Download DejaVuSans.ttf and place in src/main/resources/fonts/");
        }

        builder.toStream(outputStream);
        builder.run();

        return outputStream.toByteArray();
    }

    private static String formatCurrency(BigDecimal amount) {
        return VN_CURRENCY.format(amount);
    }

    /**
     * Chuyển số thành chữ tiếng Việt
     * Ví dụ đơn giản - bạn có thể cải thiện thêm
     */
    private static String convertNumberToWords(BigDecimal amount) {
        long number = amount.longValue();

        if (number == 0) return "Không đồng";

        final String[] units = {
                "", "một", "hai", "ba", "bốn", "năm",
                "sáu", "bảy", "tám", "chín"
        };

        final String[] scales = {
                "", "nghìn", "triệu", "tỷ", "nghìn tỷ", "triệu tỷ"
        };

        StringBuilder result = new StringBuilder();
        int scaleIndex = 0;

        while (number > 0) {
            int block = (int) (number % 1000);
            if (block != 0) {
                String blockWords = readThreeDigits(block, units);
                if (!blockWords.isEmpty()) {
                    if (scaleIndex > 0) {
                        result.insert(0, blockWords + " " + scales[scaleIndex] + " ");
                    } else {
                        result.insert(0, blockWords + " ");
                    }
                }
            }
            number /= 1000;
            scaleIndex++;
        }

        // Chuẩn hóa chuỗi
        String finalText = result.toString().trim();
        finalText = Character.toUpperCase(finalText.charAt(0)) + finalText.substring(1);
        return finalText + " đồng chẵn";
    }

    private static String readThreeDigits(int number, String[] units) {
        int hundred = number / 100;
        int ten = (number % 100) / 10;
        int unit = number % 10;

        StringBuilder sb = new StringBuilder();

        // Hàng trăm
        if (hundred > 0) {
            sb.append(units[hundred]).append(" trăm");
        }

        // Hàng chục
        if (ten > 1) { // 20, 30, 40...
            if (sb.length() > 0) sb.append(" ");
            sb.append(units[ten]).append(" mươi");
        } else if (ten == 1) { // 10–19
            if (sb.length() > 0) sb.append(" ");
            sb.append("mười");
        } else if (ten == 0 && unit > 0 && hundred > 0) {
            if (sb.length() > 0) sb.append(" ");
            sb.append("lẻ");
        }

        // Hàng đơn vị
        if (unit > 0) {
            if (sb.length() > 0) sb.append(" ");

            if (ten == 0 || ten == 1) {
                if (unit == 5 && ten > 0) sb.append("lăm");
                else sb.append(units[unit]);
            } else {
                if (unit == 1) sb.append("mốt");
                else if (unit == 5) sb.append("lăm");
                else sb.append(units[unit]);
            }
        }

        return sb.toString();
    }

    public static byte[] generateSupplierOrderPdf(SupplierOrder order, List<SupplierOrderDetail> orderDetails) throws IOException {

        // Load template
        ClassPathResource resource = new ClassPathResource("templates/invoice-supplier-order.html");
        String html = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

        // Logo
        String logoBase64 = Base64.getEncoder().encodeToString(
                Files.readAllBytes(Paths.get("uploads/images/logo.png"))
        );
        html = html.replace("{{logoImage}}", "data:image/png;base64," + logoBase64);

        // Ngày đặt hàng
        LocalDateTime orderDate = order.getOrderDate();
        html = html.replace("{{orderDay}}", String.format("%02d", orderDate.getDayOfMonth()));
        html = html.replace("{{orderMonth}}", String.format("%02d", orderDate.getMonthValue()));
        html = html.replace("{{orderYear}}", String.valueOf(orderDate.getYear()));
        html = html.replace("{{orderYear}}", String.valueOf(orderDate.getYear()));

        // Mã đơn
        html = html.replace("{{orderId}}", String.valueOf(order.getId()));

        // Tên người đặt
        html = html.replace("{{orderUserName}}", order.getUser().getFullName());

        // Thông tin nhà cung cấp
        html = html.replace("{{supplierName}}", order.getSupplier().getName());
        html = html.replace("{{supplierAddress}}", order.getSupplier().getAddress() != null ? order.getSupplier().getAddress() : "");
        html = html.replace("{{supplierPhone}}", order.getSupplier().getPhoneNumber() != null ? order.getSupplier().getPhoneNumber() : "");

        // Chi tiết sản phẩm
        StringBuilder items = new StringBuilder();
        int index = 1;
        for (SupplierOrderDetail d : orderDetails) {
            items.append(String.format("""
                            <tr>
                              <td class="text-center">%d</td>
                              <td>%d</td>
                              <td>%s</td>
                              <td class="text-center">Cái</td>
                              <td class="text-center">%d</td>
                              <td class="text-right">%s</td>
                              <td class="text-right">%s</td>
                            </tr>
                            """,
                    index++,
                    d.getProduct().getId(),
                    d.getProduct().getName(),
                    d.getQuantity(),
                    formatCurrency(d.getPrice()),
                    formatCurrency(d.getTotalMoney())
            ));
        }
        html = html.replace("{{items}}", items.toString());

        // Tổng tiền
        html = html.replace("{{totalAmount}}", formatCurrency(order.getTotalMoney()));
        html = html.replace("{{totalAmountInWords}}", convertNumberToWords(order.getTotalMoney()));

        // Footer
        html = html.replace("{{lookupUrl}}", "http://yourdomain.com/supplier-order");
        html = html.replace("{{lookupCode}}", order.getId().toString());

        // Generate PDF
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.withHtmlContent(html, "/");

        try {
            builder.useFont(() -> InvoicePdfService.class.getResourceAsStream("/fonts/DejaVuSans.ttf"),
                    "DejaVu Sans");
        } catch (Exception e) {
            System.err.println("Warning: Font not loaded for Vietnamese support");
        }

        builder.toStream(outputStream);
        builder.run();

        return outputStream.toByteArray();
    }

    public static byte[] generateSupplierInvoicePdf(SupplierInvoice order, List<SupplierInvoiceDetail> orderDetails) throws IOException {
        ClassPathResource resource = new ClassPathResource("templates/invoice-supplier.html");
        String html = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

        // Ngày hóa đơn
        LocalDateTime now = LocalDateTime.now();
        html = html.replace("{{invoiceDay}}", String.format("%02d", now.getDayOfMonth()));
        html = html.replace("{{invoiceMonth}}", String.format("%02d", now.getMonthValue()));
        html = html.replace("{{invoiceYear}}", String.valueOf(now.getYear()));
        html = html.replace("{{invoiceNumber}}", String.valueOf(order.getInvoiceNumber()));

        // Nhà cung cấp
        Supplier supplier = order.getSupplier();
        html = html.replace("{{supplierName}}", supplier.getName());
        html = html.replace("{{supplierAddress}}", supplier.getAddress() != null ? supplier.getAddress() : "");
        html = html.replace("{{supplierPhone}}", supplier.getPhoneNumber() != null ? supplier.getPhoneNumber() : "");

        // Chi tiết sản phẩm
        StringBuilder items = new StringBuilder();
        int index = 1;
        BigDecimal subTotal = BigDecimal.ZERO;
        for (SupplierInvoiceDetail d : orderDetails) {
            BigDecimal lineTotal = d.getTotalMoney();
            subTotal = subTotal.add(lineTotal);
            items.append(String.format("""
                            <tr>
                              <td>%d</td>
                              <td>%d</td>
                              <td class="text-left">%s</td>
                              <td>Cái</td>
                              <td>%d</td>
                              <td class="text-right">%s</td>
                              <td class="text-right">%s</td>
                            </tr>
                            """,
                    index++,
                    d.getProduct().getId(),
                    d.getProduct().getName(),
                    d.getQuantity(),
                    formatCurrency(d.getPrice()),
                    formatCurrency(lineTotal)
            ));
        }
        html = html.replace("{{items}}", items.toString());

        html = html.replace("{{subTotal}}", formatCurrency(subTotal));

        // Tổng tiền
        html = html.replace("{{totalAmount}}", formatCurrency(order.getTotalMoney()));
        html = html.replace("{{totalAmountInWords}}", convertNumberToWords(order.getTotalMoney()));

        // Generate PDF
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.withHtmlContent(html, "/");
        try {
            builder.useFont(() -> InvoicePdfService.class.getResourceAsStream("/fonts/DejaVuSans.ttf"), "DejaVu Sans");
        } catch (Exception e) {
            System.err.println("Font warning");
        }
        builder.toStream(outputStream);
        builder.run();

        return outputStream.toByteArray();
    }

    public static byte[] generatePurchaseOrderPdf(PurchaseOrder order, List<PurchaseOrderDetail> orderDetails) throws IOException {

        // Load template
        ClassPathResource resource = new ClassPathResource("templates/purchase-order.html");
        String html = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

        // Logo
        String logoBase64 = Base64.getEncoder().encodeToString(
                Files.readAllBytes(Paths.get("uploads/images/logo.png"))
        );
        html = html.replace("{{logoImage}}", "data:image/png;base64," + logoBase64);

        // Ngày đặt hàng
        LocalDateTime orderDate = order.getImportDate();
        html = html.replace("{{orderDay}}", String.format("%02d", orderDate.getDayOfMonth()));
        html = html.replace("{{orderMonth}}", String.format("%02d", orderDate.getMonthValue()));
        html = html.replace("{{orderYear}}", String.valueOf(orderDate.getYear()));
        html = html.replace("{{orderYear}}", String.valueOf(orderDate.getYear()));

        // Mã đơn
        html = html.replace("{{orderId}}", String.valueOf(order.getId()));

        // Tên người đặt
        html = html.replace("{{orderUserName}}", order.getUser().getFullName());

        // Chi tiết sản phẩm
        StringBuilder items = new StringBuilder();
        int index = 1;
        for (PurchaseOrderDetail d : orderDetails) {
            items.append(String.format("""
                            <tr>
                              <td class="text-center">%d</td>
                              <td>%d</td>
                              <td>%s</td>
                              <td class="text-center">Cái</td>
                              <td class="text-center">%d</td>
                            </tr>
                            """,
                    index++,
                    d.getProduct().getId(),
                    d.getProduct().getName(),
                    d.getQuantity()
            ));
        }
        html = html.replace("{{items}}", items.toString());

        // Footer
        html = html.replace("{{lookupUrl}}", "http://yourdomain.com/supplier-order");
        html = html.replace("{{lookupCode}}", order.getId().toString());

        // Generate PDF
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.withHtmlContent(html, "/");

        try {
            builder.useFont(() -> InvoicePdfService.class.getResourceAsStream("/fonts/DejaVuSans.ttf"),
                    "DejaVu Sans");
        } catch (Exception e) {
            System.err.println("Warning: Font not loaded for Vietnamese support");
        }

        builder.toStream(outputStream);
        builder.run();

        return outputStream.toByteArray();
    }
}
