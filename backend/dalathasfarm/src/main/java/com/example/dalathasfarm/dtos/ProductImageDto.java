package com.example.dalathasfarm.dtos;

import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class ProductImageDto {
    private int productId;
    private String name;
}
