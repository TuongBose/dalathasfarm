package com.example.dalathasfarm.services.CouponCondition;

import com.example.dalathasfarm.models.CouponCondition;
import com.example.dalathasfarm.repositories.CouponConditionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CouponConditionService implements ICouponConditionService{
    private final CouponConditionRepository couponConditionRepository;


    @Override
    public List<CouponCondition> getCouponConditionByCouponId(Integer id) {
        return couponConditionRepository.findByCouponId(id);
    }
}
