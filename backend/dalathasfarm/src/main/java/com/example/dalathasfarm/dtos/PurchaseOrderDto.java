package com.example.dalathasfarm.dtos;

import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PurchaseOrderDto {
    private int supplierInvoiceId;
    private int userId;
    private LocalDate importDate;
    private String note;
    private String receiptFile;
    private List<CartItemDto> cartItems;
}
