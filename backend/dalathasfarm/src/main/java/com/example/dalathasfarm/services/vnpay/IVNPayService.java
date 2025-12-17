package com.example.dalathasfarm.services.vnpay;

import com.example.dalathasfarm.dtos.PaymentDto;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;
import java.util.Map;

public interface IVNPayService {
    String createPaymentUrl(PaymentDto paymentDTO, HttpServletRequest request);
    boolean verifyCallback(Map<String, String> params);
    void handleFailed(String txnRef, Map<String, String> params) throws Exception;
    void handleSuccess(String txnRef, Map<String, String> params) throws Exception;
//    String queryTransaction(PaymentQueryDTO paymentQueryDTO, HttpServletRequest request) throws IOException;
//    String refundTransaction(PaymentRefundDTO paymentRefundDTO) throws IOException;
}
