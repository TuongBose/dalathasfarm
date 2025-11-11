package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Occasion;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OccasionRepository extends JpaRepository<Occasion,Integer> {
    boolean existsByName(String name);
}
