import { Coupon } from "./coupon";

export interface CouponCondition {
    id: number;
    attribute: string;
    operator: string;
    value: number;
    discountAmount: number;
    coupon:Coupon;
}