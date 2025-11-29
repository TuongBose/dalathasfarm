import { Component, OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { ActivatedRoute, RouterLink } from "@angular/router";
import { OrderService } from "../../services/order.service";
import { HeaderComponent } from "../header/header.component";
import { FooterComponent } from "../footer/footer.component";
import { SafePipe } from "../../pipes/safe.pipe";
import { ToastService } from "../../services/toast.service";

@Component({
  selector: 'app-payment-success',
  standalone: true,
  templateUrl: './payment-success.component.html',
  styleUrl: './payment-success.component.css',
  imports: [
    CommonModule, HeaderComponent, FooterComponent, SafePipe,
    RouterLink
  ]
})

export class PaymentSuccessComponent implements OnInit {
  orderId: number | null = null;
  invoiceUrl: string = '';
  loading: boolean = true;

  constructor(
    private activatedRoute: ActivatedRoute,
    private orderService: OrderService,
    private toastService: ToastService
  ) { }

  ngOnInit(): void {
    this.activatedRoute.queryParams.subscribe(params => {
      this.orderId = params['orderId'] ? Number(params['orderId']) : null;
      const invoiceFile = params['invoiceFile'];

      debugger
      if (this.orderId && invoiceFile) {
        this.invoiceUrl = this.orderService.viewFile(invoiceFile);
        this.loading = false;
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