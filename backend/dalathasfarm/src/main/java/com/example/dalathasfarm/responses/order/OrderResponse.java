package com.example.dalathasfarm.responses.order;

import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.responses.orderdetail.OrderDetailResponse;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OrderResponse {
    private Integer id;
    private Integer userId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String address;
    private String note;
    private String status;
    private LocalDate orderDate;
    private LocalDate shippingDate;
    private BigDecimal totalPrice;
    private String paymentMethod;
    private String shippingMethod;
    private Boolean isActive;
    private String vnpTxnRef;
    private String invoiceFile;
    private List<OrderDetailResponse> orderDetailResponses;

    public static OrderResponse fromOrder(Order order, List<OrderDetailResponse> orderDetailResponses) {
        return OrderResponse.builder()
                .id(order.getId())
                .userId(order.getUser().getId())
                .fullName(order.getFullName())
                .email(order.getEmail())
                .phoneNumber(order.getPhoneNumber())
                .address(order.getAddress())
                .note(order.getNote())
                .status(order.getStatus().name())
                .orderDate(order.getOrderDate())
                .shippingDate(order.getShippingDate())
                .totalPrice(order.getTotalMoney())
                .paymentMethod(order.getPaymentMethod().name())
                .shippingMethod(order.getShippingMethod().name())
                .isActive(order.getIsActive())
                .vnpTxnRef(order.getVnpTxnRef())
                .invoiceFile(order.getInvoiceFile())
                .orderDetailResponses(orderDetailResponses)
                .build();
    }
}
