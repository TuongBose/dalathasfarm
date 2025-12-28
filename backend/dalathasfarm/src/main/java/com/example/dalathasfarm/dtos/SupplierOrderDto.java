package com.example.dalathasfarm.dtos;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class SupplierOrderDto {
    private int supplierId;
    private int userId;
    private BigDecimal totalMoney;
    private String note;
    private List<CartItemDto> cartItems;
}
