import { Component, DOCUMENT, inject, OnInit } from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { CommonModule } from "@angular/common";
import { ToastService } from "../../services/toast.service";
import { TokenService } from "../../services/token.service";
import { CartService } from "../../services/cart.service";
import { CouponService } from "../../services/coupon.service";
import { PaymentService } from "../../services/payment.service";
import { FeedbackService } from "../../services/feedback.service";
import { NotificationService } from "../../services/notification.service";
import { CategoryService } from "../../services/category.service";
import { ProductService } from "../../services/product.service";
import { UserService } from "../../services/user.service";
import { OrderService } from "../../services/order.service";
import { OccasionService } from "../../services/occasion.service";
import { ProvinceService } from "../../services/province.service";

@Component({
  selector: 'app-base',
  standalone: true,
  templateUrl: './base.component.html',
  styleUrl: './base.component.css',
  imports: [
    CommonModule
  ]
})

export class BaseComponent {
  toastService = inject(ToastService);
  router: Router = inject(Router);
  categoryService: CategoryService = inject(CategoryService);
  occasionService: OccasionService = inject(OccasionService);
  productService: ProductService = inject(ProductService);
  tokenService: TokenService = inject(TokenService);
  activatedRoute: ActivatedRoute = inject(ActivatedRoute);
  userService: UserService = inject(UserService);
  cartService: CartService = inject(CartService);
  couponService: CouponService = inject(CouponService);
  orderService: OrderService = inject(OrderService);
  paymentService: PaymentService = inject(PaymentService);
  feedbackService:FeedbackService=inject(FeedbackService);
  notificationService:NotificationService=inject(NotificationService);
  provinceService:ProvinceService=inject(ProvinceService);

  generateVisiblePageArray(currentPage: number, totalPages: number): number[] {
    const maxVisiblePages = 5;
    const halfVisiblePages = Math.floor(maxVisiblePages / 2);
    if (currentPage < 1 || totalPages < 1 || currentPage > totalPages) {
      return []; // Trả về mảng rỗng nếu giá trị không hợp lệ
    }
    let startPage = Math.max(currentPage - halfVisiblePages, 1);
    let endPage = Math.min(startPage + maxVisiblePages - 1, totalPages);

    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = Math.max(endPage - maxVisiblePages + 1, 1);
    }
    return new Array(endPage - startPage + 1).fill(0)
      .map((_, index) => startPage + index);
  }
}