package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Category;
import com.example.dalathasfarm.models.Occasion;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.Supplier;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Integer> {
    boolean existsByName(String name);
    Page<Product> findAll(Pageable pageable); // Phan trang
    List<Product> findByCategory(Category category);
    List<Product> findByOccasion(Occasion occasion);
    List<Product> findBySupplier(Supplier supplier);

    @Query(
            "SELECT p FROM Product p WHERE " +
                    "(:categoryId IS NULL OR :categoryId = 0 OR p.category.id = :categoryId) " +
                    "AND (:occasionId IS NULL OR :occasionId = 0 OR p.occasion.id = :occasionId) " +
                    "AND (:keyword IS NULL OR :keyword = '' OR p.name LIKE CONCAT('%', :keyword, '%') OR p.description LIKE CONCAT('%', :keyword, '%'))"
    )
    Page<Product> searchProducts(
            @Param("categoryId") Integer categoryId,
            @Param("occasionId") Integer occasionId,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    @Query("SELECT p FROM Product p WHERE p.id IN :productId")
    List<Product> findProductByProductIds(@Param("productId") List<Integer> productId);

//    @Query("SELECT p FROM Product p JOIN p.favorites f WHERE f.user.id = :userId")
//    List<Product> findFavoriteProductsByUserId(@Param("userId") int userId);
}
