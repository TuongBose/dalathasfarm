import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';
import { OrderResponse } from '../../responses/order.response';

@Component({
  selector: 'app-orders',
  standalone: true,
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class OrdersComponent extends BaseComponent implements OnInit {
  orderResponses: OrderResponse[] = [];
  orderResponse?: OrderResponse;
  currentPage: number = 0;
  itemsPerPage: number = 12;
  totalPages: number = 0;
  visiblePages: number[] = [];
  pages: number[] = [];

  // Bộ lọc tìm kiếm
  searchOrderId: string = '';
  searchUserId: string = '';
  searchKeyword: string = '';

  ngOnInit(): void {
    this.getAllOrder();
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
  }

  getImage(imageName: string): string {
    return `${environment.apiBaseUrl}/products/images/${imageName}`;
  }

  getAllOrder() {
    this.orderService.getAllOrder(this.searchKeyword, this.currentPage, this.itemsPerPage).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.orderResponses = response.data.orderResponses;
        this.totalPages = response.data.totalPages;
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching category: ', error)
      }
    })
  }

  openAddCategoryModal() {
    alert('Chức năng thêm  sản phẩm mới – bạn sẽ làm modal sau nhé!');
    // this.router.navigate(['/home/products/add']); // hoặc mở modal
  }

  openEditCategoryModal(category: Category) {
    alert(`Chỉnh sửa sản phẩm: ${category.name} (ID: ${category.id})`);
    // Mở form chỉnh sửa ở đây
  }

  confirmDelete(categoryId: number, categoryName: string) {
    if (confirm(`Bạn có chắc muốn xóa danh mục sản phẩm:\n"${categoryName}" không?`)) {
      this.productService.deleteProduct(categoryId).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Xóa danh mục sản phẩm thành công!',
            title: 'Thành công',
            type: 'success'
          });
          this.getAllOrder();
        },
        error: (error: HttpErrorResponse) => {
          this.toastService.showToast({
            error,
            defaultMsg: 'Xóa danh mục sản phẩm không thành công!',
            title: 'Thông báo',
            delay: 3000,
            type: 'danger'
          });
        }
      });
    }
  }

  onPageChange(page: number) {
    debugger;
    this.currentPage = page < 0 ? 0 : page;
    this.getAllOrder();
    localStorage.setItem('currentProductPage', String(this.currentPage));
  }

  onSearch() {
    this.currentPage = 0;

    // Ưu tiên tìm theo ID đơn hàng
    if (this.searchOrderId.trim()) {
      const id = Number(this.searchOrderId);
      if (!isNaN(id)) {
        this.getOrderById(id);
        return;
      }
    }

    // Tiếp theo là tìm theo ID khách hàng
    if (this.searchUserId.trim()) {
      const id = Number(this.searchUserId);
      if (!isNaN(id)) {
        this.getAllOrderByUserId(id);
        return;
      }
    }

    this.getAllOrder();
  }

  getOrderById(orderId: number) {
    this.orderService.getOrderById(orderId).subscribe({
      next: (response: ApiResponse) => {
        this.orderResponses = [response.data];
      },
      error: (err: HttpErrorResponse) => {
        this.toastService.showToast({
          defaultMsg: 'Đơn hàng không tồn tại hoặc đã bị hủy.',
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      }
    });
  }

  getAllOrderByUserId(userId: number) {
    this.orderService.getOrdersByUserId(userId).subscribe({
      next: (apiResponse: ApiResponse) => {
        this.orderResponses = apiResponse.data;
      },
      error: (err: HttpErrorResponse) => {
        this.toastService.showToast({
          defaultMsg: 'Lỗi tải danh sách lịch sử đơn hàng',
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      }
    })
  }

  getStatusClass(status: string): string {
    switch (status?.toLowerCase()) {
      case 'pending': return 'bg-warning text-dark';
      case 'confirmed': return 'bg-info';
      case 'shipping': return 'bg-primary';
      case 'delivered': return 'bg-success';
      case 'cancelled': return 'bg-danger';
      default: return 'bg-secondary';
    }
  }

  getStatusText(status: string): string {
    const map: any = {
      pending: 'Chờ xác nhận',
      confirmed: 'Đã xác nhận',
      shipping: 'Đang giao',
      delivered: 'Đã giao',
      cancelled: 'Đã hủy'
    };
    return map[status?.toLowerCase()] || status;
  }

  get isOrderIdFilled(): boolean {
    return this.searchOrderId.trim().length > 0;
  }

  get isUserIdFilled(): boolean {
    return this.searchUserId.trim().length > 0;
  }

  get isKeywordFilled(): boolean {
    return this.searchKeyword.trim().length > 0;
  }

  onInputChange(field: 'orderId' | 'userId' | 'keyword') {
    if (field === 'orderId' && this.searchOrderId.trim()) {
      this.searchUserId = '';
      this.searchKeyword = '';
    } else if (field === 'userId' && this.searchUserId.trim()) {
      this.searchOrderId = '';
      this.searchKeyword = '';
    } else if (field === 'keyword' && this.searchKeyword.trim()) {
      this.searchOrderId = '';
      this.searchUserId = '';
    }
  }
  
  get isAnyFilterFilled(): boolean {
    return this.isOrderIdFilled || this.isUserIdFilled || this.isKeywordFilled;
  }

  clearAllFilters() {
    this.searchOrderId = '';
    this.searchUserId = '';
    this.searchKeyword = '';
    this.currentPage = 0;
    this.getAllOrder();
  }
}
