package com.example.dalathasfarm.responses.purchaseorder;

import com.example.dalathasfarm.models.PurchaseOrder;
import com.example.dalathasfarm.models.Supplier;
import com.example.dalathasfarm.models.SupplierInvoice;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.purchaseorderdetail.PurchaseOrderDetailResponse;
import com.example.dalathasfarm.responses.supplierinvoicedetail.SupplierInvoiceDetailResponse;
import com.example.dalathasfarm.responses.user.UserResponse;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PurchaseOrderResponse {
    private Integer id;
    private Integer supplierInvoiceId;
    private UserResponse userResponse;
    private LocalDateTime importDate;
    private String note;
    private String receiptFile;
    private List<PurchaseOrderDetailResponse>purchaseOrderDetailResponses;

    public static PurchaseOrderResponse fromPurchaseOrder(PurchaseOrder purchaseOrder, List<PurchaseOrderDetailResponse>purchaseOrderDetailResponses) {
        return PurchaseOrderResponse.builder()
                .id(purchaseOrder.getId())
                .supplierInvoiceId(purchaseOrder.getId())
                .userResponse(UserResponse.fromUser(purchaseOrder.getUser()))
                .importDate(purchaseOrder.getImportDate())
                .note(purchaseOrder.getNote())
                .receiptFile(purchaseOrder.getReceiptFile())
                .purchaseOrderDetailResponses(purchaseOrderDetailResponses)
                .build();
    }
}
