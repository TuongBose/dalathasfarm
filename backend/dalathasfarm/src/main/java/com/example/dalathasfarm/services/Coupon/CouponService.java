package com.example.dalathasfarm.services.Coupon;

import com.example.dalathasfarm.models.Coupon;
import com.example.dalathasfarm.models.CouponCondition;
import com.example.dalathasfarm.repositories.CouponConditionRepository;
import com.example.dalathasfarm.repositories.CouponRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CouponService implements ICouponService {
    private final CouponRepository couponRepository;
    private final CouponConditionRepository couponConditionRepository;

    @Override
    public double calculateCouponValue(String couponCode, double totalAmount) {
        Coupon coupon = couponRepository.findByCode(couponCode)
                .orElseThrow(() -> new IllegalArgumentException("Coupon not found"));

        if (!coupon.getIsActive()) {
            throw new IllegalArgumentException("Coupon is not active");
        }

        return calculateDiscount(coupon, totalAmount);
    }

    private double calculateDiscount(Coupon coupon, double totalAmount) {
        List<CouponCondition> conditions = couponConditionRepository.findByCouponId(coupon.getId());
        double discount = 0.0;
        double updatedTotalAmount = totalAmount;
        for (CouponCondition condition : conditions) {
            // EAV(Entity - Attribute - Value) Model
            String attribute = condition.getAttribute();
            String operator = condition.getOperator();
            String value = condition.getValue();

            double percentDiscount = Double.parseDouble(String.valueOf(condition.getDiscountAmount()));

            switch (attribute) {
                case "minimum_amount":
                    double requiredAmount = Double.parseDouble(value);
                    if (compareNumber(updatedTotalAmount, requiredAmount, operator)) {
                        discount += applyDiscount(updatedTotalAmount, percentDiscount);
                    }
                    break;
                case "application_date":
                    LocalDate currentDate = LocalDate.now();
                    if (operator.equals("=")) {
                        LocalDate comparedDate = LocalDate.parse(value);
                        if (currentDate.isEqual(comparedDate)) {
                            discount += applyDiscount(updatedTotalAmount, percentDiscount);
                        }
                    } else if (operator.equals("BETWEEN")) {
                        String[] dates = value.split(",");
                        LocalDate start = LocalDate.parse(dates[0].trim());
                        LocalDate end = LocalDate.parse(dates[1].trim());

                        if (!currentDate.isBefore(start) && !currentDate.isAfter(end)) {
                            discount += applyDiscount(updatedTotalAmount, percentDiscount);
                        }
                    }
                    break;

                default:
                    System.out.println("Unknown coupon attribute: " + attribute);
            }

            updatedTotalAmount = updatedTotalAmount - discount;
        }
        return discount;
    }

    private double applyDiscount(double currentTotal, double discountAmount) {
        return currentTotal * (discountAmount / 100);
    }

    private boolean compareNumber(double a, double b, String operator) {
        return switch (operator) {
            case ">" -> a > b;
            case ">=" -> a >= b;
            case "<" -> a < b;
            case "<=" -> a <= b;
            case "=" -> a == b;
            default -> false;
        };
    }
}

