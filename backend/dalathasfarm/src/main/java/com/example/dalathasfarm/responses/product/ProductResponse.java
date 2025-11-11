package com.example.dalathasfarm.responses.product;

import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.responses.BaseResponse;
import com.example.dalathasfarm.responses.productimage.ProductImageResponse;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductResponse extends BaseResponse {

    private Integer id;
    private String name;
    private BigDecimal price;
    private String description;
    private Integer stockQuantity;
    private Integer categoryId;
    private Integer occasionId;
    private String thumbnail;
    private int totalPages;
    private List<ProductImageResponse> productImageResponses;

    public static ProductResponse fromProduct(Product product) {
        ProductResponse newSanPhamResponse = ProductResponse
                .builder()
                .id(product.getId())
                .name(product.getName())
                .price(product.getPrice())
                .description(product.getDescription())
                .stockQuantity(product.getStockQuantity())
                .categoryId(product.getCategory().getId())
                .occasionId(product.getOccasion().getId())
                .thumbnail(product.getThumbnail())
                .totalPages(0)
                .build();
        newSanPhamResponse.setCreatedAt(product.getCreatedAt());
        newSanPhamResponse.setUpdatedAt(product.getUpdatedAt());
        return newSanPhamResponse;
    }

    public static ProductResponse fromProductForDetail(Product product, List<ProductImageResponse> productImageResponses) {
        ProductResponse newProductResponse = ProductResponse
                .builder()
                .id(product.getId())
                .name(product.getName())
                .price(product.getPrice())
                .description(product.getDescription())
                .stockQuantity(product.getStockQuantity())
                .categoryId(product.getCategory().getId())
                .occasionId(product.getOccasion().getId())
                .thumbnail(product.getThumbnail())
                .totalPages(0)
                .productImageResponses(productImageResponses)
                .build();
        newProductResponse.setCreatedAt(product.getCreatedAt());
        newProductResponse.setUpdatedAt(product.getUpdatedAt());
        return newProductResponse;
    }
}
