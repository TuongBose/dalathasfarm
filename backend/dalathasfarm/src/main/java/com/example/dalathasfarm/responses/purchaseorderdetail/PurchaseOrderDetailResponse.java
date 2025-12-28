package com.example.dalathasfarm.responses.purchaseorderdetail;

import com.example.dalathasfarm.models.PurchaseOrderDetail;
import com.example.dalathasfarm.models.SupplierInvoiceDetail;
import com.example.dalathasfarm.responses.product.ProductResponse;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PurchaseOrderDetailResponse {
    private Integer purchaseOrderId;
    private ProductResponse productResponse;
    private Integer quantity;

    public static PurchaseOrderDetailResponse fromPurchaseOrderDetail(PurchaseOrderDetail purchaseOrderDetail)
    {
        return PurchaseOrderDetailResponse.builder()
                .purchaseOrderId(purchaseOrderDetail.getPurchaseOrder().getId())
                .productResponse(ProductResponse.fromProduct(purchaseOrderDetail.getProduct()))
                .quantity(purchaseOrderDetail.getQuantity())
                .build();
    }
}
