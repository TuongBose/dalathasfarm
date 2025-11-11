package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CouponRepository extends JpaRepository<Coupon, Integer> {
    Optional<Coupon> findByCode(String couponCode);

}
