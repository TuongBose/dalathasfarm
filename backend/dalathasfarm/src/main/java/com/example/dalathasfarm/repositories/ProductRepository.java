package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Product;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Integer, Product> {
}
