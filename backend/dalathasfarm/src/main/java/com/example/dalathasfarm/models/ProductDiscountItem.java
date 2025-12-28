package com.example.dalathasfarm.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "product_discount_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductDiscountItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne
    @JoinColumn(name = "product_discount_id", nullable = false)
    private ProductDiscount productDiscount;
}
