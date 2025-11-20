package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class OrderDto {
    @NotNull(message = "ID người dùng không được bỏ trống")
    private int userId;

    @NotNull(message = "Họ tên không được bỏ trống")
    private String fullName;

    private String email;

    @NotNull(message = "Số điện thoại không được bỏ trống")
    private String phoneNumber;

    private String address;

    private String note;

    @NotNull(message = "Tổng số tiền hóa đơn không được bỏ trống")
    private BigDecimal totalPrice;

    @NotNull(message = "Phương thức thanh toán không được bỏ trống")
    private String paymentMethod;

    @NotNull(message = "Phương thức nhận hàng không được bỏ trống")
    private String shippingMethod;

    @NotNull(message = "Ngày giao hàng không được bỏ trống")
    private LocalDate shippingDate;

    private String status;
    private String vnpTxnRef;
    private String couponCode;

    @NotNull(message = "Danh sách sản phẩm không được bỏ trống")
    private List<CartItemDto> cartItems;
}
