import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { environment } from '../../environments/environment';
import {  RouterModule } from '@angular/router';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Product } from '../../models/product';
import { OrderDto } from '../../dtos/order.dto';

@Component({
  selector: 'app-order',
  standalone: true,
  templateUrl: './order.component.html',
  styleUrl: './order.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule
  ]
})
export class OrderComponent extends BaseComponent implements OnInit {
  private formBuilder = inject(FormBuilder);
  private cdr = inject(ChangeDetectorRef);

  indexError: number[] = [];
  hasStockIssue: boolean = false;
  loading: boolean = false;
  cart: Map<number, number> = new Map();
  orderForm: FormGroup;
  cartItems: { product: Product, quantity: number }[] = [];
  couponDiscount: number = 0; //số tiền được discount từ coupon
  couponApplied: boolean = false;
  totalAmount: number = 0;
  orderData: OrderDto = {
    userId: 0,
    fullName: '',
    email: '',
    phoneNumber: '',
    address: '',
    note: '',
    totalPrice: 0,
    paymentMethod: 'cod',
    status: '',
    cartItems: []
  }

  constructor() {
    super();

    this.orderForm = this.formBuilder.group({
      fullname: ['tuong', [Validators.required]],
      email: ['tuong@gmail.com', [Validators.email]],
      sodienthoai: ['090009848', [Validators.required, Validators.minLength(6)]],
      diachi: ['123 le trong tan, phuong 5', [Validators.required, Validators.minLength(5)]],
      ghichu: [''],
      couponCode: [''],
      phuongthucthanhtoan: ['cod']
    });

    this.cartService.cartChanged.subscribe(() => {
      this.cart = this.cartService.getCart();
      this.updateCartItems();
      this.cdr.detectChanges();
    });
  }

  ngOnInit(): void {
    debugger
    this.orderData.userId = this.tokenService.getUserId();
    this.cartService.forceRefreshCart();
    this.cart = this.cartService.getCart();
    this.updateCartItems();


    const productIds = Array.from(this.cart.keys()); // Truyền danh sách MASANPHAM từ Map giỏ hàng

    // Gọi service để lấy thông tin sản phẩm dựa trên danh sách MASANPHAM
    debugger
    if (productIds.length === 0) {
      return;
    }

    this.productService.getProductByProductIds(productIds).subscribe({
      next: (apiResponse: ApiResponse) => {
        const products: Product[] = apiResponse.data.sanPhamResponseList;
        debugger
        this.cartItems = productIds.map((productId) => {
          debugger
          const product = products.find((p) => p.id === productId);
          if (product) {
            product.thumbnail = `${environment.apiBaseUrl}/products/images/${product.thumbnail}`
          }
          return {
            product: product!,
            quantity: this.cart.get(productId)!
          };
        });

        this.cartItems.forEach((cartItem, index) => {
          if (cartItem.product.stock_quantity < cartItem.quantity) {
            this.hasStockIssue = true;
            this.indexError.push(index);
            this.toastService.showToast({
              defaultMsg: `Sản phẩm "${cartItem.product.name}" không đủ hàng trong kho (Còn ${cartItem.product.stock_quantity} sản phẩm).`,
              title: 'Thông báo',
              delay: 3000,
              type: 'danger'
            });
            this.loading = false;
            return;
          }
        });
      },
      complete: () => {
        debugger
        this.calculateTotal();
      },
      error: (error: HttpErrorResponse) => {
        debugger
        console.error(error?.error?.message ?? '')
      }
    })
  }

  placeOrder() {
    debugger
    if (this.orderForm.errors == null) {
      debugger
      if (!this.hasStockIssue) {
        // Gán giá trị từ form vào đối tuọng orderData
        /*
        this.orderData.fullname = this.orderForm.get('fullname')!.value;
        this.orderData.email=this.orderForm.get('email')!.value;
        this.orderData.sodienthoai=this.orderForm.get('sodienthoai')!.value;
        this.orderData.diachi=this.orderForm.get('diachi')!.value;
        this.orderData.ghichu=this.orderForm.get('ghichu')!.value;
        this.orderData.phuongthucthanhtoan=this.orderForm.get('phuongthucthanhtoan')!.value;
        */
        // Sử dụng toán tử spread (...) để sao chép giá trị từ form vào orderData
        this.orderData = {
          ...this.orderData,
          ...this.orderForm.value
        };
        this.orderData.cartItems = this.cartItems.map(cartItem => ({
          productId: cartItem.product.id,
          quantity: cartItem.quantity
        }));

        this.orderData.totalPrice = this.totalAmount;

        debugger
        if (this.orderData.paymentMethod === 'vnpay') {
          this.handleVnpayPayment();
        } else {
          this.handleCodPayment();
        }
      } else {
        debugger
        this.loading = false;
        this.indexError.forEach(index => {
          const cartItem = this.cartItems[index];
          this.toastService.showToast({
            defaultMsg: `Sản phẩm "${cartItem.product.name}" không đủ hàng trong kho (Còn ${cartItem.product.stock_quantity} sản phẩm).`,
            title: 'Thông báo',
            delay: 3000,
            type: 'danger'
          });
        });
      }
    }
  }

  private handleVnpayPayment(): void {
    debugger
    const amount = this.orderData.totalPrice || 0;
    this.loading = true; // Hiển thị loading
    this.paymentService.createPaymentUrl({ amount, language: 'vn' }).subscribe({
      next: (res: ApiResponse) => {
        const paymentUrl = res.data as string;
        const vnp_TxnRef = new URL(paymentUrl).searchParams.get('vnp_TxnRef') || '';

        this.orderService.placeOrder({ ...this.orderData, vnp_TxnRef }).subscribe({
          next: (placeOrderResponse: ApiResponse) => {
            this.loading = false;
            window.location.href = paymentUrl;
          },
          error: (err: HttpErrorResponse) => {
            this.loading = false;
            this.toastService.showToast({
              defaultMsg: 'Lỗi trong quá trình đặt hàng',
              title: 'Thông báo',
              delay: 3000,
              type: 'danger'
            });
          }
        });
      },
      error: (err: HttpErrorResponse) => {
        this.loading = false;
        this.toastService.showToast({
          defaultMsg: 'Lỗi kết nối đến cổng thanh toán',
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      }
    });
  }

  private handleCodPayment(): void {
    debugger
    this.loading = true;
    this.orderService.placeOrder(this.orderData).subscribe({
      next: (apiResponse: ApiResponse) => {
        this.loading = false;
        this.toastService.showToast({
          defaultMsg: 'Đặt hàng thành công',
          title: 'Thông báo',
          delay: 3000,
          type: 'success'
        });
        this.cartService.clearCart();
        this.router.navigate(['/']);
      },
      error: (error: HttpErrorResponse) => {
        this.loading = false;
        this.toastService.showToast({
          defaultMsg: 'Lỗi khi đặt hàng',
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      }
    });
  }

  calculateTotal(): void {
    this.totalAmount = this.cartItems.reduce(
      (total, item) => total + item.product.price * item.quantity,
      0
    ) - this.couponDiscount;
  }

  decreaseQuantity(index: number): void {
    if (this.cartItems[index].quantity > 1) {
      this.cartItems[index].quantity--;
      // Cập nhật lại this.cart từ this.cartItems
      this.updateCartFromCartItems();
      this.calculateTotal();
      this.cdr.detectChanges();
    }
  }

  increaseQuantity(index: number): void {
    if (this.cartItems[index].product.stock_quantity > this.cartItems[index].quantity) {
      this.cartItems[index].quantity++;
    } else {
      this.toastService.showToast({
        defaultMsg: `Sản phẩm "${this.cartItems[index].product.name}" không đủ hàng trong kho (Còn ${this.cartItems[index].product.stock_quantity} sản phẩm).`,
        title: 'Thông báo',
        delay: 3000,
        type: 'danger'
      });
    }

    debugger;
    // Cập nhật lại this.cart từ this.cartItems
    this.updateCartFromCartItems();
    this.calculateTotal();
    this.cdr.detectChanges();
  }

  confirmDelete(index: number): void {
    if (confirm('Bạn có chắc muốn xóa sản phẩm này?')) {
      // Xoa san pham khoi danh sach cartItems
      this.cartItems.splice(index, 1);
      // Cập nhật lại this.cart từ this.cartItems
      this.updateCartFromCartItems();
      // Tinh toan lai tong tien
      this.calculateTotal();
      this.cdr.detectChanges();
    }

  }

  private updateCartFromCartItems(): void {
    this.cart.clear();
    this.cartItems.forEach((item) => {
      this.cart.set(item.product.id, item.quantity);
    });
    this.cartService.setCart(this.cart);
  }

  applyCoupon(): void {
    // Xử lý áp dụng mã giảm giá
    // cập nhật giá trị totalAmount dựa trên mã giảm giá
    debugger
    const couponCode = this.orderForm.get('couponCode')!.value;
    if (!this.couponApplied && couponCode) {
      this.loading = true;
      this.calculateTotal();
      this.couponService.calculateCouponValue(couponCode, this.totalAmount).subscribe({
        next: (apiResponse: ApiResponse) => {
          this.couponDiscount = apiResponse.data as number;
          this.totalAmount -= this.couponDiscount;
          this.couponApplied = true;
          this.loading = false;
        },
        error: (err: HttpErrorResponse) => {
          this.loading = false;
          this.toastService.showToast({
            defaultMsg: 'Mã giảm giá không hợp lệ',
            title: 'Thông báo',
            delay: 3000,
            type: 'danger'
          });
        }
      });
    }
  }

  private updateCartItems(): void {
    const productIds = Array.from(this.cart.keys());
    if (productIds.length === 0) {
      this.cartItems = [];
      this.calculateTotal();
      return;
    }

    this.productService.getProductByProductIds(productIds).subscribe({
      next: (apiResponse: ApiResponse) => {
        const products: Product[] = apiResponse.data.sanPhamResponseList;
        this.cartItems = productIds.map((productId) => {
          const product = products.find((p) => p.id === productId);
          if (product) {
            product.thumbnail = `${environment.apiBaseUrl}/products/images/${product.thumbnail}`;
          }
          return {
            product: product!,
            quantity: this.cart.get(productId)!
          };
        });
        this.calculateTotal();
        this.cdr.detectChanges(); // Cập nhật giao diện
      },
      error: (error: HttpErrorResponse) => {
        console.error(error?.error?.message ?? '');
      }
    });
  }
}
