package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.math.BigDecimal;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductDto {
    @NotBlank(message = "Tên sản phẩm không được bỏ trống")
    @Size(min = 5, max = 200, message = "Tên sản phẩm phải từ 5 đến 200 ký tự")
    private String name;

    @Min(value = 0, message = "Giá sản phẩm phải lớn hơn hoặc bằng 0")
    private BigDecimal price;
    private String description;
    private String components;
    private Integer stockQuantity;
    private Integer categoryId;
    private Integer occasionId;
    private String thumbnail;
}
