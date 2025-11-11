package com.example.dalathasfarm.responses.orderdetail;

import com.example.dalathasfarm.models.OrderDetail;
import com.example.dalathasfarm.responses.product.ProductResponse;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OrderDetailResponse {
    private Integer orderId;
    private ProductResponse productResponse;
    private Integer quantity;
    private BigDecimal price;
    private BigDecimal totalMoney;

    public static OrderDetailResponse fromOrderDetail(OrderDetail orderDetail)
    {
        return OrderDetailResponse.builder()
                .orderId(orderDetail.getOrder().getId())
                .productResponse(ProductResponse.fromProduct(orderDetail.getProduct()))
                .quantity(orderDetail.getQuantity())
                .price(orderDetail.getPrice())
                .totalMoney(orderDetail.getTotalMoney())
                .build();
    }
}
