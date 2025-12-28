package com.example.dalathasfarm.services.CouponCondition;

import com.example.dalathasfarm.models.CouponCondition;

import java.util.List;

public interface ICouponConditionService {
    List<CouponCondition> getCouponConditionByCouponId(Integer id);
}
