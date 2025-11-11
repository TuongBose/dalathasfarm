package com.example.dalathasfarm.services.ProductImage;

import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.ProductImage;
import com.example.dalathasfarm.repositories.ProductImageRepository;
import com.example.dalathasfarm.responses.productimage.ProductImageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductImageService implements IProductImageService{
    private final ProductImageRepository productImageRepository;

    @Override
    public List<ProductImageResponse> getAllProductImageByProduct(Product product) {
        List<ProductImage> productImages = productImageRepository.findByProduct(product);

        List<ProductImageResponse> productImageResponses = new ArrayList<>();
        if (productImages.isEmpty()) {
            ProductImageResponse newProductImageResponse = ProductImageResponse.builder()
                    .productId(0)
                    .url("notfound.jpg")
                    .build();
            productImageResponses.add(newProductImageResponse);
        } else {
            for (ProductImage productImage : productImages) {
                ProductImageResponse newProductImageResponse = ProductImageResponse
                        .builder()
                        .productId((productImage.getProduct().getId()))
                        .url(productImage.getUrl())
                        .build();
                productImageResponses.add(newProductImageResponse);
            }
        }
        return productImageResponses;
    }

    @Override
    public ProductImage deleteProductImageById(Integer id) throws DataNotFoundException {
        ProductImage existingProductImage = productImageRepository.findById(id)
                .orElseThrow(()->new DataNotFoundException("Product image does not exist"));

        productImageRepository.deleteById(existingProductImage.getId());
        return existingProductImage;
    }
}
