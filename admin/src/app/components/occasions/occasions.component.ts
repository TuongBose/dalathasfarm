import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';
import { Occasion } from '../../models/occasion';

@Component({
  selector: 'app-occasions',
  standalone: true,
  templateUrl: './occasions.component.html',
  styleUrl: './occasions.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class OccasionsComponent extends BaseComponent implements OnInit {
  occasions: Occasion[] = [];
  currentPage: number = 0;
  itemsPerPage: number = 12;

  ngOnInit(): void {
    this.getAllOccasion(0, 6);
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
  }

  getImage(imageName: string): string {
    return `${environment.apiBaseUrl}/products/images/${imageName}`;
  }

  getAllOccasion(page: number, limit: number) {
    this.occasionService.getAllOccasion(page, limit).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.occasions = response.data;
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching occasion: ', error)
      }
    })
  }

  openAddOccasionModal() {
    alert('Chức năng thêm sản phẩm mới – bạn sẽ làm modal sau nhé!');
    // this.router.navigate(['/home/products/add']); // hoặc mở modal
  }

  openEditOccasionModal(occasion: Occasion) {
    alert(`Chỉnh sửa sản phẩm: ${occasion.name} (ID: ${occasion.id})`);
    // Mở form chỉnh sửa ở đây
  }

  confirmDelete(occasionId: number, occasionName: string) {
    if (confirm(`Bạn có chắc muốn xóa danh mục sản phẩm:\n"${occasionName}" không?`)) {
      this.productService.deleteProduct(occasionId).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Xóa danh mục sản phẩm thành công!',
            title: 'Thành công',
            type: 'success'
          });
          this.getAllOccasion(this.currentPage, this.itemsPerPage);
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
}
