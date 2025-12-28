package com.example.dalathasfarm.services.Coupon;

import com.example.dalathasfarm.models.Coupon;

import java.util.List;

public interface ICouponService {
    double calculateCouponValue(String couponCode, double totalAmount);
    List<Coupon> getAllCoupon();
    void updateStatusCoupon(Integer id)  throws Exception;
}
