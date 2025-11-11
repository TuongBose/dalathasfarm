package com.example.dalathasfarm.dtos;

import lombok.*;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class OrderDetailDto {
    private int orderId;
    private int productId;
    private int quantity;
    private BigDecimal price;
    private BigDecimal totalPrice;
}
