package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class OrderDto {
    private int userId;
    private String fullName;
    private String email;

    @NotBlank(message = "Số điện thoại không được bỏ trống")
    private String phoneNumber;

    private String address;
    private String note;
    private BigDecimal totalPrice;
    private String paymentMethod;
    private String status;
    private String vnpTxnRef;
    private String couponCode;
    private List<CartItemDto> cartItems;
}
