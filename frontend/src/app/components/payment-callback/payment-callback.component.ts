import { Component } from "@angular/core";
import { CommonModule } from "@angular/common";
import { BaseComponent } from "../base/base.component";
import { HttpErrorResponse } from "@angular/common/http";
import { ApiResponse } from "../../responses/api.response";
import { OrderStatus } from "../../models/order-status";

@Component({
  selector: 'app-auth-callback',
  standalone: true,
  templateUrl: './payment-callback.component.html',
  styleUrl: './payment-callback.component.css',
  imports: [
    CommonModule
  ]
})

export class PaymentCallbackComponent extends BaseComponent {
  loading: boolean = true;
  paymentSuccess: boolean = false;

  ngOnInit(): void {
    debugger
    // Sử dụng this.activatedRoute từ BaseComponent
    debugger
    const vnp_ResponseCode = this.activatedRoute.snapshot.queryParamMap.get('vnp_ResponseCode'); // Ma phan hoi tu VNPay
    const vnp_TxnRef = this.activatedRoute.snapshot.queryParamMap.get('vnp_TxnRef'); // Ma don hang (neu ban truyen vao khi tao URL thanh toan)

    if (vnp_ResponseCode && vnp_TxnRef) {
      if (vnp_ResponseCode === '00') {
        // Thanh toan thanh cong
        this.handlePaymentSuccess(vnp_TxnRef);
      }
      else {
        // Thanh toan khong thanh cong
        this.handlePaymentFailure(vnp_ResponseCode);
      }
    } else {
      this.handlePaymentFailure('Invalid response from VNPay');
    }
  }

  handlePaymentSuccess(vnp_TxnRef: string): void {
    debugger
    const pendingOrder = sessionStorage.getItem('pendingOrder');
    if (pendingOrder) {
      const { orderId, invoiceFile } = JSON.parse(pendingOrder);
      sessionStorage.removeItem('pendingOrder');
      // Su dung this.orderService tu BaseComponent
      this.orderService.updateOrderStatus(vnp_TxnRef, OrderStatus.Processing).subscribe({
        next: (response: ApiResponse) => {
          debugger
          this.loading = false;
          this.paymentSuccess = true;
          // Sử dụng this.toastService từ BaseComponent
          this.toastService.showToast({
            defaultMsg: 'Thanh toán thành công',
            title: 'Thông báo',
            delay: 3000,
            type: 'success'
          });
          // Sử dụng this.router từ baseComponent để chuyển hướng
          setTimeout(() => {
            debugger
            this.cartService.clearCart();
            this.router.navigate(['/payment-success'], {
              queryParams: { orderId, invoiceFile }
            });
          }, 3000);
        },
        error: (error: HttpErrorResponse) => {
          this.loading = false;
          this.paymentSuccess = false;
          this.toastService.showToast({
            defaultMsg: 'Lỗi khi cập nhật trạng thái đơn hàng',
            title: 'Thông báo',
            delay: 3000,
            type: 'danger'
          });
          setTimeout(() => {
            this.router.navigate(['/']);
          }, 3000);
        }
      })
    }
  }

  handlePaymentFailure(errorMsg: string): void {
    debugger
    this.loading = false;
    this.paymentSuccess = false;
    this.toastService.showToast({
      defaultMsg: 'Thanh toán không thành công',
      title: 'Thông báo',
      delay: 3000,
      type: 'danger'
    });
    setTimeout(() => {
      this.router.navigate(['/']);
    }, 3000);
  }
}