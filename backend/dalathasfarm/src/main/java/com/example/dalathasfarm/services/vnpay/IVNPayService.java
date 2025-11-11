package com.example.dalathasfarm.services.vnpay;

import com.example.dalathasfarm.dtos.PaymentDto;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

public interface IVNPayService {
    String createPaymentUrl(PaymentDto paymentDTO, HttpServletRequest request);
//    String queryTransaction(PaymentQueryDTO paymentQueryDTO, HttpServletRequest request) throws IOException;
//    String refundTransaction(PaymentRefundDTO paymentRefundDTO) throws IOException;
}
