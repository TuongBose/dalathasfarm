import { CommonModule, CurrencyPipe, DatePipe, DecimalPipe } from "@angular/common";
import { Component, OnInit } from "@angular/core";
import { BaseComponent } from "../base/base.component";
import { ApiResponse } from "../../responses/api.response";
import { environment } from "../../environments/environment";
import { CartItemDto } from "../../dtos/cartitem.dto";

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, CurrencyPipe, DatePipe, DecimalPipe],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css',
})
export class DashboardComponent extends BaseComponent implements OnInit {
  data: DashboardData | null = null;
  loading = true;


  ngOnInit(): void {
    this.dashboardService.getDashboard().subscribe({
      next: (res: ApiResponse) => {
        debugger
        this.data = res.data as DashboardData;

        if (this.data.last10DaysRevenue) {
          this.data.last10DaysRevenue = this.data.last10DaysRevenue.reverse();
        }

        this.loading = false;
      },
      error: (err) => {
        console.error(err);
        this.loading = false;
      }
    });
  }

  getImageUrl(thumbnail: string): string {
    debugger
    return `${environment.apiBaseUrl}/products/images/${thumbnail}`;
  }

  createImportOrderForLowStock() {
    if (!this.data || this.data.lowStockProducts.length === 0) {
      this.toastService.showToast({
        defaultMsg: 'Không có sản phẩm nào sắp hết hàng',
        type: 'info'
      });
      return;
    }

    const suggestedQuantity = 10;
    const cartItems: CartItemDto[] = this.data.lowStockProducts.map(p => ({
      productId: p.id,
      quantity: suggestedQuantity
    }));
    const params = {
      autoFillLowStock: true,
      items: JSON.stringify(cartItems)
    };

    this.router.navigate(['/home/supplier-orders'], { queryParams: params });
  }
}
