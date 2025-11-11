package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<ProductImage, Integer> {
    List<ProductImage> findByProduct(Product product);
}
