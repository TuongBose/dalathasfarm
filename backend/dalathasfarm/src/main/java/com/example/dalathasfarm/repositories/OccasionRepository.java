package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Occasion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface OccasionRepository extends JpaRepository<Occasion,Integer> {
    boolean existsByName(String name);

    @Query("SELECT o FROM Occasion o " +
            "WHERE o.isActive = TRUE " +
            "AND o.startDate <= :today " +
            "AND o.endDate >= :today")
    List<Occasion> findActiveOccasionsForToday(@Param("today") LocalDate today);
}
