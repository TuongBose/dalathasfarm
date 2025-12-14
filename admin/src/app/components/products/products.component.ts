import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Product } from '../../models/product';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Component({
  selector: 'app-products',
  standalone: true,
  templateUrl: './products.component.html',
  styleUrl: './products.component.scss',
  imports: [
    CommonModule,
    FormsModule,
  ]

})
export class ProductsComponent extends BaseComponent implements OnInit {
  products: Product[] = [];
  categories: Category[] = [];
  currentPage: number = 0;
  itemsPerPage: number = 12;
  pages: number[] = [];
  totalPages: number = 0;
  visiblePages: number[] = [];
  keyword: string = "";
  selectedCategoryId: number = 0;
  selectedOccasionId: number = 0;
  isPressAddToCart: boolean = false;
  categoryProductsMap: { [categoryId: number]: Product[] } = {};
  componentsHtml: SafeHtml = '';

  constructor(private sanitizer: DomSanitizer) { super() }

  ngOnInit(): void {
    debugger
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
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

  getProductsByCategory(categoryId: number): Product[] {
    if (this.categoryProductsMap[categoryId]) {
      return this.categoryProductsMap[categoryId];
    }

    // Gọi API lấy sản phẩm theo occasion
    this.productService.getAllProduct('', categoryId, 0, 0, 4).subscribe({
      next: (apiResponse: ApiResponse) => {
        const products = apiResponse.data.productResponses.map((p: Product) => {
          p.thumbnailUrl = `${environment.apiBaseUrl}/products/images/${p.thumbnail}`;
          debugger
          return p;
        });
        this.categoryProductsMap[categoryId] = products;
      },
      error: (err) => {
        console.error(`Lỗi tải sản phẩm cho category ${categoryId}:`, err);
        this.categoryProductsMap[categoryId] = [];
      }
    });

    // Trả về mảng rỗng tạm thời
    return this.categoryProductsMap[categoryId] || [];
  }

  getAllProduct(keyword: string, selectedCategoryId: number, selectedOccasionId: number, page: number, limit: number) {
    debugger
    this.productService.getAllProduct(keyword, selectedCategoryId, selectedOccasionId, page, limit).subscribe({
      next: (apiresponse: ApiResponse) => {
        debugger
        const response = apiresponse.data;
        response.productResponses.forEach((product: Product) => {
          product.thumbnailUrl = `${environment.apiBaseUrl}/products/images/${product.thumbnail}`;
          product.safeComponents = this.sanitizer.bypassSecurityTrustHtml(product.components)
        })
        this.products = response.productResponses;
        this.totalPages = response.totalPages;
        this.visiblePages = this.generateVisiblePageArray(this.currentPage, this.totalPages);
      },
      complete: () => {
        debugger;
      },
      error: (error: HttpErrorResponse) => {
        this.toastService.showToast({
          error: error,
          defaultMsg: 'Lấy dữ liệu sản phẩm không thành công',
          title: 'Lỗi'
        })
      }
    });
  }

  onPageChange(page: number) {
    debugger;
    this.currentPage = page < 0 ? 0 : page;
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
    localStorage.setItem('currentProductPage', String(this.currentPage));
  }

  searchProduct() {
    this.currentPage = 0;
    this.itemsPerPage = 12;
    debugger
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
  }

  onProductClick(productId: number) {
    debugger
    this.router.navigate(['/products', productId]);
  }

  addToCart(event: Event, productId: number): void {
    event.stopPropagation();
    debugger

    this.isPressAddToCart = true;
    if (productId) {
      this.cartService.addToCart(productId, 1);
      this.toastService.showToast({
        defaultMsg: 'Thêm vào giỏ hàng thành công',
        title: 'Thông báo',
        delay: 3000,
        type: 'success'
      });
    }
    else {
      console.error("Không thể thêm sản phẩm vào giỏ hàng vì San Phẩm là Null.");
    }
  }

  buyNow(event: Event, productId: number): void {
    event.stopPropagation(); // Ngăn sự kiện click lan ra div cha
    const token = this.tokenService.getToken();
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    if (productId) {
      this.cartService.addToCart(productId, 1);
      this.router.navigate(['/orders']); // Chuyển ngay đến trang order
      return;
    } else {
      console.error("Không thể mua ngay vì San Phẩm là Null.");
    }
  }

  scrollToProducts(): void {
    const productSection = document.getElementById('product-section');
    if (productSection) {
      productSection.scrollIntoView({ behavior: 'smooth' });
    }
  }

  openAddProductModal() {
    alert('Chức năng thêm sản phẩm mới – bạn sẽ làm modal sau nhé!');
    // this.router.navigate(['/home/products/add']); // hoặc mở modal
  }

  openEditProductModal(product: Product) {
    alert(`Chỉnh sửa sản phẩm: ${product.name} (ID: ${product.id})`);
    // Mở form chỉnh sửa ở đây
  }

  confirmDelete(productId: number, productName: string) {
    if (confirm(`Bạn có chắc muốn xóa sản phẩm:\n"${productName}" không?`)) {
      this.productService.deleteProduct(productId).subscribe({
        next: () => {
          this.toastService.showToast({
            defaultMsg: 'Xóa sản phẩm thành công!',
            title: 'Thành công',
            type: 'success'
          });
          this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
        },
        error: (error: HttpErrorResponse) => {
          this.toastService.showToast({
            error,
            defaultMsg: 'Xóa sản phẩm không thành công!',
            title: 'Thông báo',
            delay: 3000,
            type: 'danger'
          });
        }
      });
    }
  }
}
