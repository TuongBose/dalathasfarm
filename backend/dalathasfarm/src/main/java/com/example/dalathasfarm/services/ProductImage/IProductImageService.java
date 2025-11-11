package com.example.dalathasfarm.services.ProductImage;

import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.ProductImage;
import com.example.dalathasfarm.responses.productimage.ProductImageResponse;

import java.util.List;

public interface IProductImageService {
    List<ProductImageResponse> getAllProductImageByProduct(Product product);
    ProductImage deleteProductImageById(Integer id) throws DataNotFoundException;
}
