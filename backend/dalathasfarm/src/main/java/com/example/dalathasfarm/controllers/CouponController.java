package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.coupon.CouponCalculationResponse;
import com.example.dalathasfarm.services.Coupon.ICouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("${api.prefix}/coupons")
@RequiredArgsConstructor
public class CouponController {
    private final ICouponService couponService;

    @GetMapping("/calculate")
    public ResponseEntity<ResponseObject> calculateCouponValue(
            @RequestParam("couponCode") String couponCode,
            @RequestParam("totalAmount") double totalAmount
    ) {
        double finalAmount = couponService.calculateCouponValue(couponCode, totalAmount);

        CouponCalculationResponse response = CouponCalculationResponse.builder()
                .result(finalAmount)
                .build();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Calculate coupon successfully")
                .status(HttpStatus.OK)
                .data(response)
                .build());
    }
}
