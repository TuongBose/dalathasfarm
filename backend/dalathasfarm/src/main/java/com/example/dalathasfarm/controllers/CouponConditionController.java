package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.models.Coupon;
import com.example.dalathasfarm.models.CouponCondition;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.coupon.CouponCalculationResponse;
import com.example.dalathasfarm.services.Coupon.ICouponService;
import com.example.dalathasfarm.services.CouponCondition.ICouponConditionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("${api.prefix}/coupon-conditions")
@RequiredArgsConstructor
public class CouponConditionController {
    private final ICouponConditionService couponConditionService;

    @GetMapping("{id}")
    public ResponseEntity<ResponseObject> getCouponConditionById( @Valid @PathVariable Integer id   ) {
         List< CouponCondition> conditions = couponConditionService.getCouponConditionByCouponId(id);

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get all coupon conditions successfully")
                .status(HttpStatus.OK)
                .data(conditions)
                .build());
    }
}
