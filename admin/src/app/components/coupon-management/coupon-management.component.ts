import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';
import { Coupon } from '../../models/coupon';
import { CouponCondition } from '../../models/coupon-condition';

@Component({
  selector: 'app-coupon-management',
  standalone: true,
  templateUrl: './coupon-management.component.html',
  styleUrl: './coupon-management.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class CouponManagementComponent extends BaseComponent implements OnInit {
  coupons: Coupon[] = [];
  couponConditions: { [couponId: number]: CouponCondition[] } = {};
  expandedCouponId: number | null = null;
  loading = true;

  ngOnInit(): void {
    this.loadAllCoupons();
  }

  loadAllCoupons() {
    this.loading = true;
    this.couponService.getAllCoupon().subscribe({
      next: (response: ApiResponse) => {
        this.coupons = response.data;
        this.coupons.forEach(coupon => {
          this.loadCouponConditions(coupon.id);
        });
        this.loading = false;
      },
      error: (err) => {
        this.toastService.showToast({
          defaultMsg: 'Không thể tải danh sách coupon',
          type: 'danger'
        });
        this.loading = false;
      }
    });
  }

toggleCouponStatus(couponId: number) {
  const coupon = this.coupons.find(c => c.id === couponId);
  if (!coupon) return;

  this.couponService.updateStatusCoupon(couponId).subscribe({
    next: () => {
      // Cập nhật local trước để UI phản hồi nhanh
      coupon.isActive = !coupon.isActive;

      this.toastService.showToast({
        defaultMsg: `Coupon "${coupon.code}" đã được ${coupon.isActive ? 'BẬT' : 'TẮT'} thành công!`,
        type: 'success',
        delay: 3000
      });
    },
    error: (err) => {
      this.toastService.showToast({
        defaultMsg: 'Cập nhật trạng thái coupon thất bại: ' + (err.error?.message || 'Lỗi server'),
        type: 'danger'
      });
    }
  });
}

  loadCouponConditions(couponId: number) {
    debugger
    this.couponConditionService.getCouponConditionByCouponId(couponId).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.couponConditions[couponId] = response.data;
      },
      error: () => {
        this.couponConditions[couponId] = [];
      }
    });
  }

  toggleDetails(couponId: number) {
    this.expandedCouponId = this.expandedCouponId === couponId ? null : couponId;
  }

  getOperatorText(operator: string): string {
    const map: { [key: string]: string } = {
      'GREATER_THAN_OR_EQUAL': '≥',
      'LESS_THAN_OR_EQUAL': '≤',
      'EQUAL': '=',
      'GREATER_THAN': '>',
      'LESS_THAN': '<'
    };
    return map[operator] || operator;
  }

  getAttributeText(attribute: string): string {
    const map: { [key: string]: string } = {
      'MIN_ORDER_VALUE': 'Giá trị đơn hàng tối thiểu',
      'MAX_DISCOUNT_AMOUNT': 'Giảm tối đa',
      'QUANTITY_PER_USER': 'Số lần dùng mỗi khách'
    };
    return map[attribute] || attribute;
  }
}