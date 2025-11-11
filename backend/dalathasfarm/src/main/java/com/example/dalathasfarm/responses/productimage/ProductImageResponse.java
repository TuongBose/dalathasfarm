package com.example.dalathasfarm.responses.productimage;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductImageResponse {
    private Integer productId;
    private String url;
}
