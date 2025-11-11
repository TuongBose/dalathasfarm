package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.CouponCondition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CouponConditionRepository extends JpaRepository<CouponCondition, Integer> {
    List<CouponCondition> findByCouponId(Integer couponId);
}
