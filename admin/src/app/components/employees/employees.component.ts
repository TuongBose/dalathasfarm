import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';
import { UserResponse } from '../../responses/user/user.response';

@Component({
  selector: 'app-employees',
  standalone: true,
  templateUrl: './employees.component.html',
  styleUrl: './employees.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class EmployeesComponent extends BaseComponent implements OnInit {
  users: UserResponse[] = [];
  currentPage: number = 0;
  itemsPerPage: number = 12;

  ngOnInit(): void {
    this.getAllUserAdmin(0, 12);
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
  }

  getImage(imageName: string): string {
    return `${environment.apiBaseUrl}/products/images/${imageName}`;
  }

  getAllUserAdmin(page: number, limit: number) {
    this.userService.getAllUserEmployee(page, limit).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.users = response.data.userResponseList;
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching admins: ', error)
      }
    })
  }

  openAddCategoryModal() {
    alert('Chức năng thêm  sản phẩm mới – bạn sẽ làm modal sau nhé!');
    // this.router.navigate(['/home/products/add']); // hoặc mở modal
  }

  openEditCategoryModal() {
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
          this.getAllUserAdmin(this.currentPage, this.itemsPerPage);
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
