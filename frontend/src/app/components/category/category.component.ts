import { Component, OnInit } from '@angular/core';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { Product } from '../../models/product';
import { Category } from '../../models/category';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-category',
  standalone: true,
  templateUrl: './category.component.html',
  styleUrl: './category.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
  ]

})
export class CategoryComponent extends BaseComponent implements OnInit {
  products: Product[] = [];
  category?: Category;
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

  constructor() {
    super();
  }

  ngOnInit(): void {
    debugger
    this.activatedRoute.paramMap.subscribe(params => {
      const idParam = params.get('id');
      if (idParam !== null) {
        this.selectedCategoryId = +idParam; // Chuyển đổi sang số
      } else {
        console.error('Cannot find category');
        this.router.navigate(['/']); // Điều hướng về trang chủ nếu không có tham số
        return;
      }
    });
    this.getCategoryById(this.selectedCategoryId);
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
  }

  getCategoryById(categoryId: number) {
    debugger;
    this.categoryService.getCategoryById(categoryId).subscribe({
      next: (apiResponse: ApiResponse) => {
        debugger;
        this.category = apiResponse.data;
      },
      complete: () => { debugger; },
      error: (error: HttpErrorResponse) => {
        this.toastService.showToast({
          error: error,
          defaultMsg: 'Lấy dữ liệu loại sản phẩm không thành công',
          title: 'Lỗi'
        })
      }
    })
  }

  getOccasionThumbnailUrl(thumbnail: string): string {
    return `${environment.apiBaseUrl}/products/images/${thumbnail}`;
  }

  getOccasionBannerUrl(banner: string): string {
    return `${environment.apiBaseUrl}/products/images/${banner}`;
  }

  getAllProduct(keyword: string, selectedCategoryId: number, selectedOccasionId: number, page: number, limit: number) {
    debugger
    this.productService.getAllProduct(keyword, selectedCategoryId, selectedOccasionId, page, limit).subscribe({
      next: (apiresponse: ApiResponse) => {
        debugger
        const response = apiresponse.data;
        response.productResponses.forEach((product: Product) => {
          product.thumbnailUrl = `${environment.apiBaseUrl}/products/images/${product.thumbnail}`;
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
    const token = this.tokenService.getToken();
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

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
}
