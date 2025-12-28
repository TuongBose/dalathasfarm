package com.example.dalathasfarm.responses.supplierorderdetail;

import com.example.dalathasfarm.models.SupplierOrderDetail;
import com.example.dalathasfarm.responses.product.ProductResponse;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SupplierOrderDetailResponse {
    private Integer supplierOrderId;
    private ProductResponse productResponse;
    private Integer quantity;
    private BigDecimal price;
    private BigDecimal totalMoney;

    public static SupplierOrderDetailResponse fromSupplierOrderDetail(SupplierOrderDetail supplierOrderDetail)
    {
        return SupplierOrderDetailResponse.builder()
                .supplierOrderId(supplierOrderDetail.getSupplierOrder().getId())
                .productResponse(ProductResponse.fromProduct(supplierOrderDetail.getProduct()))
                .quantity(supplierOrderDetail.getQuantity())
                .price(supplierOrderDetail.getPrice())
                .totalMoney(supplierOrderDetail.getTotalMoney())
                .build();
    }
}
