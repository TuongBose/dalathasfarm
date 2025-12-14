import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-categories',
  standalone: true,
  templateUrl: './categories.component.html',
  styleUrl: './categories.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class CategoriesComponent extends BaseComponent implements OnInit {
  categories: Category[] = [];
  currentPage: number = 0;
  itemsPerPage: number = 12;

  ngOnInit(): void {
    this.getAllCategory(0, 6);
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
  }

  getImage(imageName: string): string {
    return `${environment.apiBaseUrl}/products/images/${imageName}`;
  }

  getAllCategory(page: number, limit: number) {
    this.categoryService.getAllCategory(page, limit).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.categories = response.data;
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
          this.getAllCategory(this.currentPage, this.itemsPerPage);
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
