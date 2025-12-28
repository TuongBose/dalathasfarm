package com.example.dalathasfarm.dtos;

import com.example.dalathasfarm.models.Supplier;
import com.example.dalathasfarm.models.SupplierInvoice;
import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
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
public class SupplierInvoiceDto {
    private int supplierId;
    private String invoiceNumber;
    private LocalDate invoiceDate;
    private BigDecimal totalMoney;
    private BigDecimal taxAmount;
    private String paymentMethod;
    private String paymentStatus;
    private String note;
    private List<CartItemDto> cartItems;
}
