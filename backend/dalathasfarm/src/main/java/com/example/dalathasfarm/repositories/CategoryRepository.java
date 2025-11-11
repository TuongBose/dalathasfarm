package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Integer> {
    boolean existsByName(String name);
}