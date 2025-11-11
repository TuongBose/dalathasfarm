package com.example.dalathasfarm.services.Product;

import com.example.dalathasfarm.dtos.ProductDto;
import com.example.dalathasfarm.dtos.ProductImageDto;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.ProductImage;
import com.example.dalathasfarm.responses.product.ProductResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import java.util.List;

public interface IProductService {
    Product createProduct(ProductDto productDto) throws Exception;
    Product getProductById(Integer id) throws Exception;
    Page<ProductResponse> getAllProduct(String keyword,
                                        Integer categoryId,
                                        PageRequest pageRequest) throws Exception;
    Product updateProduct(Integer id, ProductDto productDto) throws Exception;
    void deleteProduct(Integer id);
    boolean existsByName(String name);
    ProductImage createProductImage(ProductImageDto productImageDto) throws Exception;
    List<Product> findProductByIdList(List<Integer> ids);
}
