package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.models.Coupon;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.coupon.CouponCalculationResponse;
import com.example.dalathasfarm.services.Coupon.ICouponService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @GetMapping("")
    public ResponseEntity<ResponseObject> getAllCoupon() {
        List<Coupon> coupons = couponService.getAllCoupon();

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get all coupon successfully")
                .status(HttpStatus.OK)
                .data(coupons)
                .build());
    }

    @PutMapping("{id}")
    public ResponseEntity<ResponseObject> updateStatusCoupon(@Valid @PathVariable Integer id) throws Exception{
        couponService.updateStatusCoupon(id);

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update status coupon successfully")
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }
}
