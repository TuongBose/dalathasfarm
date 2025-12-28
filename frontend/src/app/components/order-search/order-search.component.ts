import { Component, OnInit } from '@angular/core';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { OrderResponse } from '../../responses/order.response';
import { OrderService } from '../../services/order.service';
import { OrderDetail } from '../../models/order.detail';
import { ToastService } from '../../services/toast.service';
import { SafePipe } from '../../pipes/safe.pipe';
import { ApiResponse } from '../../responses/api.response';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-order-search',
  standalone: true,
  templateUrl: './order-search.component.html',
  styleUrl: './order-search.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    SafePipe,
    FormsModule
  ]
})
export class OrderSearchComponent {
  orderIdInput: string = '';
  orderId: number | null = null;
  invoiceUrl: string = '';
  loading: boolean = false;
  searching: boolean = false;
  notFound: boolean = false;

  constructor(
    private orderService: OrderService,
    private toastService: ToastService
  ) { }

  searchOrder() {
    const id = Number(this.orderIdInput.trim());
    if (!this.orderIdInput || isNaN(id) || id <= 0) {
      this.toastService.showToast({
        defaultMsg: 'Vui lòng nhập mã đơn hàng hợp lệ!',
        type: 'warning'
      });
      return;
    }

    this.searching = true;
    this.notFound = false;
    this.orderId = null;
    this.invoiceUrl = '';

    this.orderService.getOrderById(id).subscribe({
      next: (response: ApiResponse) => {
        this.searching = false;
        const order = response.data;

        if (!order || !order.invoiceFile) {
          this.notFound = true;
          this.toastService.showToast({
            defaultMsg: 'Không tìm thấy đơn hàng hoặc chưa có hóa đơn!',
            type: 'danger'
          });
          return;
        }

        this.orderId = order.id;
        this.invoiceUrl = this.orderService.viewFile(order.invoiceFile);
        this.notFound = false;

        this.toastService.showToast({
          defaultMsg: `Tìm thấy đơn hàng #${this.orderId}!`,
          type: 'success',
          delay: 3000
        });
      },
      error: (err) => {
        this.searching = false;
        this.notFound = true;
        this.toastService.showToast({
          defaultMsg: 'Đơn hàng không tồn tại hoặc đã bị hủy.',
          type: 'danger'
        });
      }
    });
  }

  printPdfOnly(): void {
    fetch(this.invoiceUrl)
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

  downloadPdf(): void {
    fetch(this.invoiceUrl)
      .then(response => {
        if (!response.ok) throw new Error('Download failed');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `hoa-don-don-hang-${this.orderId}.pdf`;
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
}
