package com.example.dalathasfarm.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "supplier_invoices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierInvoice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;

    @Column(name = "invoice_number", nullable = false, unique = true)
    private String invoiceNumber;

    @Column(name = "invoice_date",nullable = false)
    private LocalDateTime invoiceDate;

    @Column(name="total_money",nullable = false, precision = 12, scale = 2)
    @DecimalMin(value = "0.0", inclusive = true)
    private BigDecimal totalMoney;

    @Column(name = "tax_amount",precision = 12, scale = 2)
    @DecimalMin(value = "0.0", inclusive = true)
    private BigDecimal taxAmount;

    @Column(name = "payment_method")
    @Enumerated(EnumType.STRING)
    private SupplierInvoicePaymentMethod paymentMethod;

    @Column(name = "payment_status")
    @Enumerated(EnumType.STRING)
    private SupplierInvoicePaymentStatus paymentStatus;

    private String note;

    public enum SupplierInvoicePaymentMethod { BankTransfer, Cash }
    public enum SupplierInvoicePaymentStatus { Unpaid, Paid }
}
