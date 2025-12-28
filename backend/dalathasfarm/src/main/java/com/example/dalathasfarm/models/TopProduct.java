package com.example.dalathasfarm.models;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class TopProduct {
    private Integer productId;
    private String productName;
    private String thumbnail;
    private long quantitySold;
    private BigDecimal revenue;
}
