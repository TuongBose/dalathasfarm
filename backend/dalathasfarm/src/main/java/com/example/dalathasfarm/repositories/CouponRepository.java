package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CouponRepository extends JpaRepository<Integer, Coupon> {
}
