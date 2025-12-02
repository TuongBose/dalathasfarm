import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { environment } from '../../environments/environment';
import { RouterModule } from '@angular/router';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Product } from '../../models/product';
import { OrderDto } from '../../dtos/order.dto';
import { Province } from '../../responses/province.response';
import { District } from '../../responses/district.response';
import { Ward } from '../../responses/ward.response';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { AuthModalComponent } from '../auth-modal/auth-modal.component';

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
    RouterModule
  ]
})
export class OrderComponent extends BaseComponent implements OnInit {
  firstName: string = '';
  lastName: string = '';
  phoneNumber: string = '';
  addressDetail: string = '';
  note: string = '';
  couponCode: string = '';
  paymentMethod: string = 'Cash';
  shippingMethod: string = 'Ship';
  shippingDate: string = '';

  indexError: number[] = [];
  hasStockIssue: boolean = false;
  loading: boolean = false;
  cart: Map<number, number> = new Map();
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
    paymentMethod: 'Cash',
    shippingMethod: 'Ship',
    shippingDate: new Date(),
    status: '',
    cartItems: []
  }

  provinces: Province[] = [];
  districts: District[] = [];
  wards: Ward[] = [];
  selectedProvinceCode: number | null = null;
  selectedDistrictCode: number | null = null;
  selectedWardCode: number | null = null;

  todayDate: string = new Date().toLocaleDateString('en-CA');
  maxDate: string = '';

  // ==== LỖI VALIDATE ====
  firstNameError: string = '';
  lastNameError: string = '';
  phoneError: string = '';
  addressError: string = '';
  provinceError: string = '';
  districtError: string = '';
  wardError: string = '';
  shippingDateError: string = '';

  constructor(private cdr: ChangeDetectorRef, private modalService: NgbModal) {
    super();

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

    this.setShippingDateRange();

    this.loadProvinces();

    const productIds = Array.from(this.cart.keys()); // Truyền danh sách MASANPHAM từ Map giỏ hàng

    // Gọi service để lấy thông tin sản phẩm dựa trên danh sách MASANPHAM
    debugger
    if (productIds.length === 0) {
      return;
    }

    this.productService.getProductByProductIds(productIds).subscribe({
      next: (apiResponse: ApiResponse) => {
        const products: Product[] = apiResponse.data.productResponses;
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
          if (cartItem.product.stockQuantity < cartItem.quantity) {
            this.hasStockIssue = true;
            this.indexError.push(index);
            this.toastService.showToast({
              defaultMsg: `Sản phẩm "${cartItem.product.name}" không đủ hàng trong kho (Còn ${cartItem.product.stockQuantity} sản phẩm).`,
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

  setShippingDateRange() {
    const now = new Date();
    const currentHour = now.getHours();
    let minDate = new Date();

    // Nếu đã qua 12h trưa → không cho chọn hôm nay nữa
    if (currentHour >= 12) {
      minDate.setDate(minDate.getDate() + 1); // Ngày mai
    }

    this.todayDate = this.formatDate(minDate);

    const max = new Date();
    max.setMonth(max.getMonth() + 6);
    this.maxDate = max.toISOString().split('T')[0];
  }

  private formatDate(date: Date): string {
    return date.toLocaleDateString('en-CA');
  }

  loadProvinces() {
    this.provinceService.getProvinces().subscribe({
      next: (data) => {
        this.provinces = data;
      },
      error: () => {
        this.toastService.showToast({ defaultMsg: 'Không tải được danh sách tỉnh/thành', type: 'danger' });
      }
    });
  }

  onProvinceChange() {
    this.districts = [];
    this.wards = [];
    this.selectedDistrictCode = null;
    this.selectedWardCode = null;

    const province = this.provinces.find(p => p.code === this.selectedProvinceCode);
    if (province) this.districts = province.districts;

    this.validateProvince();
    this.validateDistrict();
    this.validateWard();
  }

  onDistrictChange() {
    this.wards = [];
    this.selectedWardCode = null;

    const district = this.districts.find(d => d.code === this.selectedDistrictCode);
    if (district) this.wards = district.wards;

    this.validateDistrict();
    this.validateWard();
  }

  onWardChange() {
    this.validateWard();
  }

  validateFirstName() {
    if (!this.firstName.trim()) this.firstNameError = 'Vui lòng nhập tên';
    else this.firstNameError = '';
  }

  validateLastName() {
    if (!this.lastName.trim()) this.lastNameError = 'Vui lòng nhập họ';
    else this.lastNameError = '';
  }

  validatePhone() {
    if (!this.phoneNumber) {
      this.phoneError = 'Vui lòng nhập số điện thoại';
    } else if (!/^\d{9,11}$/.test(this.phoneNumber)) {
      this.phoneError = 'Số điện thoại phải từ 9-11 chữ số';
    } else {
      this.phoneError = '';
    }
  }

  validateAddress() {
    if (!this.addressDetail.trim()) this.addressError = 'Vui lòng nhập địa chỉ chi tiết';
    else if (this.addressDetail.trim().length < 5) this.addressError = 'Địa chỉ quá ngắn';
    else this.addressError = '';
  }

  validateProvince() {
    if (this.shippingMethod === 'Ship' && !this.selectedProvinceCode) {
      this.provinceError = 'Vui lòng chọn tỉnh/thành';
    } else {
      this.provinceError = '';
    }
  }

  validateDistrict() {
    if (this.shippingMethod === 'Ship' && !this.selectedDistrictCode) {
      this.districtError = 'Vui lòng chọn quận/huyện';
    } else {
      this.districtError = '';
    }
  }

  validateWard() {
    if (this.shippingMethod === 'Ship' && !this.selectedWardCode) {
      this.wardError = 'Vui lòng chọn phường/xã';
    } else {
      this.wardError = '';
    }
  }

  validateShippingDate() {
    if (!this.shippingDate) {
      this.shippingDateError = 'Vui lòng chọn ngày giao hàng';
    } else {
      this.shippingDateError = '';
    }
  }

  private validateRequiredFields(): boolean {
    // Luôn validate
    this.validateFirstName();
    this.validateLastName();
    this.validatePhone();
    this.validateShippingDate();

    // Chỉ validate khi là GIAO HÀNG TẬN NƠI
    if (this.shippingMethod === 'Ship') {
      this.validateAddress();
      this.validateProvince();
      this.validateDistrict();
      this.validateWard();
    } else {
      // Nếu là Pickup → bỏ qua các field này
      this.addressError = '';
      this.provinceError = '';
      this.districtError = '';
      this.wardError = '';
    }

    // Trả về true nếu KHÔNG CÓ LỖI nào
    return !this.firstNameError &&
      !this.lastNameError &&
      !this.phoneError &&
      !this.addressError &&
      !this.provinceError &&
      !this.districtError &&
      !this.wardError &&
      !this.shippingDateError;
  }

  placeOrder() {
    debugger
    const isFormValid = this.validateRequiredFields();
    const hasStockError = this.hasStockIssue;
    if (this.cartItems.length === 0) {
      this.toastService.showToast({
        defaultMsg: 'Giỏ hàng của bạn đang trống!',
        type: 'warning',
        delay: 4000
      });
      return;
    }

    if (isFormValid && !hasStockError) {
      this.createOrderAndProceed();
      return;
    }

    if (hasStockError) {
      debugger
      this.loading = false;
      this.indexError.forEach(index => {
        const cartItem = this.cartItems[index];
        this.toastService.showToast({
          defaultMsg: `Sản phẩm "${cartItem.product.name}" không đủ hàng trong kho (Còn ${cartItem.product.stockQuantity} sản phẩm).`,
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      });
      return;
    }

    if (!isFormValid) {
      this.toastService.showToast({
        defaultMsg: 'Vui lòng kiểm tra lại thông tin bắt buộc',
        type: 'danger',
        delay: 4000
      });
    }

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

    // // Gộp họ tên
    // const fullName = `${this.lastName.trim()} ${this.firstName.trim()}`.trim();

    // // Gộp địa chỉ
    // const provinceName = this.provinces.find(p => p.code === this.selectedProvinceCode)?.name || '';
    // const districtName = this.districts.find(d => d.code === this.selectedDistrictCode)?.name || '';
    // const wardName = this.wards.find(w => w.code === this.selectedWardCode)?.name || '';

    // const fullAddress = [this.addressDetail, wardName, districtName, provinceName]
    //   .filter(Boolean)
    //   .join(', ');

    // const orderData: OrderDto = {
    //   userId: this.tokenService.getUserId(),
    //   fullName,
    //   phoneNumber: this.phoneNumber,
    //   address: fullAddress,
    //   note: this.note,
    //   totalPrice: this.totalAmount - this.couponDiscount,
    //   paymentMethod: this.paymentMethod,
    //   shippingMethod: this.shippingMethod,
    //   shippingDate: this.shippingMethod === 'Ship' ? new Date(this.shippingDate) : new Date(),
    //   cartItems: this.cartItems.map(item => ({
    //     productId: item.product.id,
    //     quantity: item.quantity
    //   })),
    //   status: '',
    //   email: '',
    // };

    // debugger
    // if (this.orderData.paymentMethod === 'BankTransfer') {
    //   this.handleVnpayPayment();
    // } else {
    //   this.handleCodPayment();
    // }
  }

  createOrderAndProceed() {
    const fullName = `${this.lastName.trim()} ${this.firstName.trim()}`.trim();

    let fullAddress = '';
    if (this.shippingMethod === 'Ship') {
      const provinceName = this.provinces.find(p => p.code === this.selectedProvinceCode)?.name || '';
      const districtName = this.districts.find(d => d.code === this.selectedDistrictCode)?.name || '';
      const wardName = this.wards.find(w => w.code === this.selectedWardCode)?.name || '';
      fullAddress = [this.addressDetail.trim(), wardName, districtName, provinceName]
        .filter(Boolean)
        .join(', ');
    } else {
      fullAddress = 'Lấy hàng tại cửa hàng';
    }

    this.orderData = {
      ...this.orderData,
      userId: this.tokenService.getUserId(),
      fullName,
      phoneNumber: this.phoneNumber,
      address: fullAddress,
      note: this.note || '',
      totalPrice: this.totalAmount,
      paymentMethod: this.paymentMethod,
      shippingMethod: this.shippingMethod,
      shippingDate: new Date(this.shippingDate),
      couponCode:this.couponApplied?this.couponCode:undefined,
      cartItems: this.cartItems.map(item => ({
        productId: item.product.id,
        quantity: item.quantity
      })),
      status: '',
      email: ''
    };

    if (this.paymentMethod === 'BankTransfer') {
      this.handleVnpayPayment();
    } else {
      this.handleCodPayment();
    }
  }

  private handleVnpayPayment(): void {
    debugger
    const amount = this.orderData.totalPrice || 0;
    this.loading = true; // Hiển thị loading
    this.paymentService.createPaymentUrl({ amount, language: 'vn' }).subscribe({
      next: (res: ApiResponse) => {
        debugger
        const paymentUrl = res.data as string;
        const vnpTxnRef = new URL(paymentUrl).searchParams.get('vnp_TxnRef') || '';

        this.orderService.placeOrder({ ...this.orderData, vnpTxnRef }).subscribe({
          next: (placeOrderResponse: ApiResponse) => {
            debugger
            const data = placeOrderResponse.data;
            const orderId = data.id;
            const invoiceFile = data.invoiceFile;

            sessionStorage.setItem('pendingOrder', JSON.stringify({
              orderId,
              invoiceFile
            }));
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
        debugger
        const data = apiResponse.data;
        const orderId = data.id;
        const invoiceFile = data.invoiceFile;

        this.loading = false;
        this.toastService.showToast({
          defaultMsg: 'Đặt hàng thành công',
          title: 'Thông báo',
          delay: 3000,
          type: 'success'
        });
        this.cartService.clearCart();
        this.router.navigate(['/payment-success'], {
          queryParams: {
            orderId: orderId,
            invoiceFile: invoiceFile
          }
        });
      },
      error: (error: HttpErrorResponse) => {
        debugger;
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
    if (this.cartItems[index].product.stockQuantity > this.cartItems[index].quantity) {
      this.cartItems[index].quantity++;
    } else {
      this.toastService.showToast({
        defaultMsg: `Sản phẩm "${this.cartItems[index].product.name}" không đủ hàng trong kho (Còn ${this.cartItems[index].product.stockQuantity} sản phẩm).`,
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

  async confirmDelete(index: number) {
    const result = await this.toastService.showConfirmToast({
      message: 'Bạn có chắc muốn xoá sản phẩm này?',
      title: 'Xác nhận xoá',
      type: 'warning',
      okText: 'Xoá',
      cancelText: 'Hủy'
    });
    if (result) {
      // Xoa san pham khoi danh sach cartItems
      this.cartItems.splice(index, 1);
      // Cập nhật lại this.cart từ this.cartItems
      this.updateCartFromCartItems();
      // Tinh toan lai tong tien
      this.calculateTotal();
      this.cdr.detectChanges();
      window.location.reload();
    }
  }

  private updateCartFromCartItems(): void {
    this.cart.clear();
    this.cartItems.forEach((item) => {
      this.cart.set(item.product.id, item.quantity);
    });
    this.cartService.setCart(this.cart);
  }

  removeCoupon(): void {
    this.couponCode = '';
    this.couponDiscount = 0;
    this.couponApplied = false;
    this.calculateTotal();
    this.toastService.showToast({
      defaultMsg: 'Đã xóa mã giảm giá',
      type: 'info'
    });
  }

  applyCoupon(): void {
    debugger
    // Xử lý áp dụng mã giảm giá
    // cập nhật giá trị totalAmount dựa trên mã giảm giá
    if (!this.couponCode.trim()) {
      this.toastService.showToast({
        defaultMsg: 'Vui lòng nhập mã giảm giá',
        type: 'warning',
        delay: 3000
      });
      return;
    }
    debugger
    if (this.couponApplied) {
      this.toastService.showToast({
        defaultMsg: 'Bạn đã áp dụng mã giảm giá rồi!',
        type: 'info',
        delay: 3000
      });
      return;
    }

    if (!this.couponApplied && this.couponCode) {
      this.loading = true;
      this.couponService.calculateCouponValue(this.couponCode, this.totalAmount).subscribe({
        next: (apiResponse: ApiResponse) => {
          debugger
          this.couponDiscount = apiResponse.data.result as number;
          

          if (this.couponDiscount > 0) {
            this.calculateTotal();
          this.couponApplied = true;
            this.toastService.showToast({
              defaultMsg: `Áp dụng mã "${this.couponCode}" thành công! Bạn được giảm ${this.couponDiscount.toLocaleString('vi-VN')}₫`,
              type: 'success',
              delay: 5000
            });
          } else {
            this.toastService.showToast({
              defaultMsg: 'Mã giảm giá không hợp lệ hoặc không áp dụng được',
              type: 'danger',
              delay: 4000
            });
          }

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

  openAuthModal() {
    this.modalService.open(AuthModalComponent, {
      centered: true,
      size: 'md',
      windowClass: 'auth-modal-window'
    });
  }
}
