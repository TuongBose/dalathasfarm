import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { OrderResponse } from '../../responses/order.response';
import { OrderDetail } from '../../models/order.detail';
import { HttpErrorResponse } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { AuthModalComponent } from '../auth-modal/auth-modal.component';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-order-history',
  standalone: true,
  templateUrl: './order-history.component.html',
  styleUrl: './order-history.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class OrderHistoryComponent extends BaseComponent implements OnInit {
  orders: OrderResponse[] = [];
  loading: boolean = false;
  userId: number = 0;
  selectedOrder: OrderResponse | null = null;
  activeTab: string = 'all';

  pendingCount: number = 0;
  processingCount: number = 0;
  shippingCount: number = 0;
  deliveredCount: number = 0;
  cancelledCount: number = 0;

  tabs = [
    { key: 'all', label: 'Tất cả', icon: 'fas fa-list-ul', count: this.orders.length },
    { key: 'pending', label: 'Chờ xác nhận', icon: 'fas fa-clock', count: this.pendingCount },
    { key: 'processing', label: 'Đang xử lý', icon: 'fas fa-cog', count: this.processingCount },
    { key: 'shipping', label: 'Đang giao', icon: 'fas fa-shipping-fast', count: this.shippingCount },
    { key: 'delivered', label: 'Đã giao', icon: 'fas fa-check-circle', count: this.deliveredCount },
    { key: 'cancelled', label: 'Đã hủy', icon: 'fas fa-times-circle', count: this.cancelledCount }
  ];

  constructor(private modalService: NgbModal) { super() }

  ngOnInit(): void {
    this.userId = this.tokenService.getUserId();
    debugger
    if (this.userId !== 1) {
      this.loadOrders();
    }
  }

  loadOrders() {
    this.orderService.getOrdersByUserId(this.userId).subscribe({
      next: (apiResponse: ApiResponse) => {
        this.orders = (apiResponse.data as OrderResponse[]).sort((a, b) => b.id - a.id);

        this.pendingCount = this.orders.filter(o => o.status.toLowerCase() === 'pending').length;
        this.processingCount = this.orders.filter(o => o.status.toLowerCase() === 'processing').length;
        this.shippingCount = this.orders.filter(o => o.status.toLowerCase() === 'shipping').length;
        this.deliveredCount = this.orders.filter(o => o.status.toLowerCase() === 'delivered').length;
        this.cancelledCount = this.orders.filter(o => o.status.toLowerCase() === 'cancelled').length;

        this.tabs = [
          { key: 'all', label: 'Tất cả', icon: 'fas fa-list-ul me-2', count: this.orders.length },
          { key: 'pending', label: 'Chờ xác nhận', icon: 'fas fa-clock me-2', count: this.pendingCount },
          { key: 'processing', label: 'Đang xử lý', icon: 'fas fa-cog me-2', count: this.processingCount },
          { key: 'shipping', label: 'Đang giao', icon: 'fas fa-truck me-2', count: this.shippingCount },
          { key: 'delivered', label: 'Đã giao', icon: 'fas fa-check-circle me-2', count: this.deliveredCount },
          { key: 'cancelled', label: 'Đã hủy', icon: 'fas fa-times-circle me-2', count: this.cancelledCount }
        ];
      },
      error: (err: HttpErrorResponse) => {
        this.loading = false;
        this.toastService.showToast({
          defaultMsg: 'Lỗi tải danh sách lịch sử đơn hàng',
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      }
    })
  }

  async cancelOrder(orderId: number) {
    const result = await this.toastService.showConfirmToast({
      message: 'Bạn có chắc muốn hủy đơn hàng này?',
      title: 'Xác nhận hủy',
      type: 'warning',
      okText: 'Hủy',
      cancelText: 'Hủy'
    });
    if (result) {
      this.orderService.cancelOrder(orderId).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Đơn hàng đã được hủy thành công!',
            type: 'success',
            delay: 4000
          });
          this.loadOrders(); // Refresh danh sách để cập nhật trạng thái
        },
        error: (err) => {
          this.toastService.showToast({
            defaultMsg: 'Hủy đơn thất bại: ' + (err.error?.message || 'Lỗi server'),
            type: 'danger'
          });
        }
      });
    }
  }

  loadOrderDetails(orderId: number) {
    this.orderDetailService.getOrderDetailsByOrderId(orderId).subscribe({
      next: (apiResponse: ApiResponse) => {
        const details = apiResponse.data as any[];
        const orderDetails: OrderDetail[] = details.map(item => ({
          id: item.id || 0,
          order: null as any,
          product: item.productResponse,
          price: item.price,
          quantity: item.quantity,
          totalMoney: item.totalMoney
        }));

        // Cập nhật vào orders
        this.orders = this.orders.map(order =>
          order.id === orderId
            ? { ...order, orderDetails }
            : order
        );

        // Mở chi tiết
        this.selectedOrder = this.orders.find(o => o.id === orderId) || null;
      },
      error: () => {
        this.toastService.showToast({
          defaultMsg: 'Không thể tải chi tiết đơn hàng',
          type: 'warning'
        });
      }
    });
  }

  get filteredOrders(): OrderResponse[] {
    if (this.activeTab === 'all') {
      return this.orders;
    }
    return this.orders.filter(order =>
      order.status.toLowerCase() === this.activeTab.toLowerCase()
    );
  }

  setActiveTab(tab: string) {
    this.activeTab = tab;
    this.selectedOrder = null;
  }

  getStatusText(status: string): string {
    const map: { [key: string]: string } = {
      pending: 'Chờ xác nhận',
      processing: 'Đang xử lý',
      shipping: 'Đang giao',
      delivered: 'Đã giao',
      cancelled: 'Đã hủy'
    };
    return map[status.toLowerCase()] || status;
  }

  toggleOrderDetails(order: OrderResponse) {
    if (this.selectedOrder?.id === order.id) {
      this.selectedOrder = null;
    } else {
      if (!order.orderDetails || order.orderDetails.length === 0) {
        this.loadOrderDetails(order.id);
      } else {
        this.selectedOrder = order;
      }
    }
  }

  getStatusColor(status: string): string {
    switch (status.toLowerCase()) {
      case 'pending': return 'warning';
      case 'confirmed': return 'info';
      case 'shipping': return 'primary';
      case 'delivered': return 'success';
      case 'cancelled': return 'danger';
      default: return 'secondary';
    }
  }

  getProductThumbnail(thumbnail: string): string {
    return `${environment.apiBaseUrl}/products/images/${thumbnail}`;
  }

  printPdfOnly(fileName: string): void {
    const invoiceUrl = this.orderService.viewFile(fileName);
    fetch(invoiceUrl)
      .then(response => response.blob())
      .then(blob => {
        const blobUrl = URL.createObjectURL(blob);
        const printWindow = window.open(blobUrl, '_blank');

        printWindow?.addEventListener('load', () => {
          setTimeout(() => {
            printWindow.print();
            // Tự động đóng sau khi in (tùy chọn)
            // printWindow.close();
          }, 500);
        });
      })
      .catch(err => {
        console.error('Lỗi in PDF:', err);
        this.toastService.showToast({
          defaultMsg: 'Không thể in hóa đơn. Vui lòng tải xuống và in thủ công.',
          type: 'warning'
        });
      });
  }

  downloadPdf(fileName: string, orderId: number): void {
    const invoiceUrl = this.orderService.viewFile(fileName);
    fetch(invoiceUrl)
      .then(response => {
        if (!response.ok) throw new Error('Download failed');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `hoa-don-don-hang-${orderId}.pdf`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        this.toastService.showToast({
          defaultMsg: 'Đã tải hóa đơn về máy!',
          type: 'success',
          delay: 3000
        });
      })
      .catch(err => {
        console.error('Lỗi tải PDF:', err);
        this.toastService.showToast({
          defaultMsg: 'Không thể tải hóa đơn. Vui lòng thử lại.',
          type: 'danger'
        });
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