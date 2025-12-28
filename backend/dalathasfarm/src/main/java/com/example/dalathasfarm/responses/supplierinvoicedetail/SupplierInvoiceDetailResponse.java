package com.example.dalathasfarm.responses.supplierinvoicedetail;

import com.example.dalathasfarm.models.SupplierInvoiceDetail;
import com.example.dalathasfarm.models.SupplierOrderDetail;
import com.example.dalathasfarm.responses.product.ProductResponse;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SupplierInvoiceDetailResponse {
    private Integer supplierOrderId;
    private ProductResponse productResponse;
    private Integer quantity;
    private BigDecimal price;
    private BigDecimal totalMoney;

    public static SupplierInvoiceDetailResponse fromSupplierInvoiceDetail(SupplierInvoiceDetail supplierInvoiceDetail)
    {
        return SupplierInvoiceDetailResponse.builder()
                .supplierOrderId(supplierInvoiceDetail.getSupplierInvoice().getId())
                .productResponse(ProductResponse.fromProduct(supplierInvoiceDetail.getProduct()))
                .quantity(supplierInvoiceDetail.getQuantity())
                .price(supplierInvoiceDetail.getPrice())
                .totalMoney(supplierInvoiceDetail.getTotalMoney())
                .build();
    }
}
