import { Component, OnInit } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
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
  selector: 'app-home',
  standalone: true,
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
    RouterLink
  ]

})
export class HomeComponent extends BaseComponent implements OnInit {
  products: Product[] = [];
  currentPage: number = 0;
  itemsPerPage: number = 12;
  pages: number[] = [];
  totalPages: number = 0;
  visiblePages: number[] = [];
  keyword: string = "";
  selectedCategoryId: number = 0;
  categories: Category[] = [];
  isPressAddToCart: boolean = false;

  bannerWebPcName: string = 'banner_web_Pc_2025.jpg';
  bannerWebPcUrl?: string;

  bannerWebMobileName: string = 'banner_web_Mobile_2025.png';
  bannerWebMobileUrl?: string;

  constructor() {
    super();
  }

  ngOnInit(): void {
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.currentPage, this.itemsPerPage);
    this.getAllCategory(1, 100);
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
    this.bannerWebPcUrl = `${environment.apiBaseUrl}/products/images/${this.bannerWebPcName}`;
    this.bannerWebMobileUrl = `${environment.apiBaseUrl}/products/images/${this.bannerWebMobileName}`;
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

  getAllProduct(keyword: string, selectedCategoryId: number, page: number, limit: number) {
    debugger
    this.productService.getAllProduct(keyword, selectedCategoryId, page, limit).subscribe({
      next: (apiresponse: ApiResponse) => {
        debugger
        const response = apiresponse.data;
        response.sanPhamResponseList.forEach((product: Product) => {
          product.thumbnailUrl = `${environment.apiBaseUrl}/products/images/${product.thumbnail}`;
        })
        this.products = response.sanPhamResponseList;
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
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.currentPage, this.itemsPerPage);
    localStorage.setItem('currentProductPage', String(this.currentPage));
  }

  searchSanPham() {
    this.currentPage = 0;
    this.itemsPerPage = 12;
    debugger
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.currentPage, this.itemsPerPage);
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

  buyNow(event: Event, productId:number): void {
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
