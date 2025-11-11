package com.example.dalathasfarm.responses.product;

import lombok.*;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductListResponse {
    private List<ProductResponse> productResponses;
    private int totalPages;
}
