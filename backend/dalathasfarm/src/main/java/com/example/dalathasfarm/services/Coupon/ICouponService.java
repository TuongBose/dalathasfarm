package com.example.dalathasfarm.services.Coupon;

public interface ICouponService {
    double calculateCouponValue(String couponCode, double totalAmount);
}
