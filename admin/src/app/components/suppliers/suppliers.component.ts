import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Supplier } from '../../models/supplier';

@Component({
  selector: 'app-suppliers',
  standalone: true,
  templateUrl: './suppliers.component.html',
  styleUrl: './suppliers.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class SuppliersComponent extends BaseComponent implements OnInit {
  suppliers: Supplier[] = [];

  ngOnInit(): void {
    this.getAllSupplier();
  }

  getAllSupplier() {
    this.supplierService.getAllSupplier().subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.suppliers = response.data;
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching supplier: ', error)
      }
    })
  }

  openAddSupplierModal() {
    alert('Chức năng thêm  sản phẩm mới – bạn sẽ làm modal sau nhé!');
    // this.router.navigate(['/home/products/add']); // hoặc mở modal
  }

  openEditSupplierModal(supplier: Supplier) {
    alert(`Chỉnh sửa sản phẩm: ${supplier.name} (ID: ${supplier.id})`);
    // Mở form chỉnh sửa ở đây
  }

  confirmDelete(supplierId: number, supplierName: string) {
    if (confirm(`Bạn có chắc muốn xóa danh mục sản phẩm:\n"${supplierName}" không?`)) {
      this.productService.deleteProduct(supplierId).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Xóa danh mục sản phẩm thành công!',
            title: 'Thành công',
            type: 'success'
          });
          this.getAllSupplier();
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
