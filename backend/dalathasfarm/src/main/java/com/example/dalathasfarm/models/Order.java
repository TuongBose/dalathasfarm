package com.example.dalathasfarm.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name="fullname",nullable = false)
    private String fullName;

    private String email;

    @Column(name = "phone_number", nullable = false)
    private String phoneNumber;

    @Column(nullable = false)
    private String address;

    private String note;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @Column(name = "order_date")
    private LocalDate orderDate;

    @Column(name = "total_money",nullable = false, precision = 10, scale = 2)
    @DecimalMin(value = "0.0", inclusive = true)
    private BigDecimal totalMoney;

    @Column(name = "payment_method")
    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    @Column(name = "shipping_method")
    @Enumerated(EnumType.STRING)
    private ShippingMethod shippingMethod;

    @Column(name = "shipping_date")
    private LocalDate shippingDate;

    @Column(name = "is_active")
    private Boolean isActive;

    @Enumerated(EnumType.STRING)
    private Platform platform;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    private Coupon coupon;

    @Column(name = "vnp_txn_ref")
    private String vnpTxnRef;

    @Column(name = "invoice_file", nullable = false)
    private String invoiceFile;

    public enum OrderStatus {
        Pending, Processing, Shipping, Delivered, Cancelled
    }

    public enum PaymentMethod {
        BankTransfer, Cash
    }

    public enum ShippingMethod {
        Ship, Pickup
    }

    public enum Platform {
        Web, Mobile
    }
}
