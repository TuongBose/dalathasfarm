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
public class CouponService implements ICouponService{
    private final CouponRepository couponRepository;
    private final CouponConditionRepository couponConditionRepository;

    @Override
    public double calculateCouponValue(String couponCode, double totalAmount) {
        Coupon coupon = couponRepository.findByCode(couponCode)
                .orElseThrow(()-> new IllegalArgumentException("Coupon not found"));

        if(!coupon.getIsActive())
        {
            throw new IllegalArgumentException("Coupon is not active");
        }

        double discount = calculateDiscount(coupon, totalAmount);
        return totalAmount - discount;
    }

    private double calculateDiscount(Coupon coupon, double totalAmount)
    {
        List<CouponCondition> conditions = couponConditionRepository.findByCouponId(coupon.getId());
        double discount = 0.0;
        double updatedTotalAmount = totalAmount;
        for(CouponCondition condition : conditions ){
            // EAV(Entity - Attribute - Value) Model
            String attribute = condition.getAttribute();
            String operator = condition.getOperator();
            String value = condition.getValue();

            double percentDiscount = Double.parseDouble(String.valueOf(condition.getDiscountAmount()));

            if(attribute.equals("minimum_amount")){
                if(operator.equals(">")&&updatedTotalAmount>Double.parseDouble(value)){
                    discount += updatedTotalAmount * percentDiscount/100;
                }
            } else if (attribute.equals("application_date")) {
                LocalDate applicationDate = LocalDate.parse(value);
                LocalDate currentDate = LocalDate.now();
                if(operator.equalsIgnoreCase("BETWEEN") && currentDate.isEqual(applicationDate)){
                    discount +=updatedTotalAmount*percentDiscount/100;
                }
            }
            // Con nhieu dieu kien khac nua
            updatedTotalAmount = updatedTotalAmount - discount;
        }
        return discount;
    }
}
