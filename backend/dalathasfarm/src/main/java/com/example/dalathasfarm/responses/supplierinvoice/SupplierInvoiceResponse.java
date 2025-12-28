package com.example.dalathasfarm.responses.supplierinvoice;

import com.example.dalathasfarm.models.Supplier;
import com.example.dalathasfarm.models.SupplierInvoice;
import com.example.dalathasfarm.models.SupplierOrder;
import com.example.dalathasfarm.responses.supplierinvoicedetail.SupplierInvoiceDetailResponse;
import com.example.dalathasfarm.responses.supplierorderdetail.SupplierOrderDetailResponse;
import com.example.dalathasfarm.responses.user.UserResponse;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SupplierInvoiceResponse {
    private Integer id;
    private Supplier supplier;
    private String invoiceNumber;
    private LocalDateTime invoiceDate;
    private BigDecimal totalMoney;
    private BigDecimal taxAmount;
    private String paymentMethod;
    private String paymentStatus;
    private String note;
    private String invoiceFile;
    private Boolean isUsed;
    private List<SupplierInvoiceDetailResponse>supplierInvoiceDetailResponses;

    public static SupplierInvoiceResponse fromSupplierInvoice(SupplierInvoice supplierInvoice, List<SupplierInvoiceDetailResponse> supplierInvoiceDetailResponses) {
        return SupplierInvoiceResponse.builder()
                .id(supplierInvoice.getId())
                .supplier(supplierInvoice.getSupplier())
                .invoiceNumber(supplierInvoice.getInvoiceNumber())
                .invoiceDate(supplierInvoice.getInvoiceDate())
                .totalMoney(supplierInvoice.getTotalMoney())
                .taxAmount(supplierInvoice.getTaxAmount())
                .paymentMethod(supplierInvoice.getPaymentMethod().name())
                .paymentStatus(supplierInvoice.getPaymentStatus().name())
                .note(supplierInvoice.getNote())
                .invoiceFile(supplierInvoice.getInvoiceFile())
                .isUsed(supplierInvoice.getIsUsed())
                .supplierInvoiceDetailResponses(supplierInvoiceDetailResponses)
                .build();
    }
}
