package com.example.dalathasfarm.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "supplier_order_details")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierOrderDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_order_id", nullable = false)
    private SupplierOrder supplierOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    @Min(1)
    private Integer quantity;

    @Column(precision = 10, scale = 2, nullable = false)
    @DecimalMin(value = "0.0", inclusive = true)
    private BigDecimal price;

    @Column(name = "total_money",precision = 12, scale = 2, nullable = false)
    @DecimalMin(value = "0.0", inclusive = true)
    private BigDecimal totalMoney;
}
