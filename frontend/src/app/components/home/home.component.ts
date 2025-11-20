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
import { Occasion } from '../../models/occasion';

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
  occasions: Occasion[] = [];
  occasionsForToday: Occasion[] = [];
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
  occasionProductsMap: { [occasionId: number]: Product[] } = {};
  categoryProductsMap: { [categoryId: number]: Product[] } = {};

  bannerName: string = 'banner.jpg';
  bannerUrl?: string;

  constructor() {
    super();
  }

  ngOnInit(): void {
    this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
    this.getAllCategory(0, 6);
    this.getAllOccasion(0, 6);
    this.getTodayOccasions();
    this.currentPage = Number(localStorage.getItem('currentProductPage')) || 0;
    this.bannerUrl = `${environment.apiBaseUrl}/products/images/${this.bannerName}`;
  }

  getTodayOccasions() {
    this.occasionService.getTodayOccasions().subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.occasionsForToday = response.data;
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching occasion: ', error)
      }
    })
  }

  getOccasionThumbnailUrl(thumbnail: string): string {
    return `${environment.apiBaseUrl}/products/images/${thumbnail}`;
  }

  getOccasionBannerUrl(banner: string): string {
    return `${environment.apiBaseUrl}/products/images/${banner}`;
  }

  getAllOccasion(page: number, limit: number) {
    this.occasionService.getAllOccasion(page, limit).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.occasions = response.data.slice(0, 5);
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching category: ', error)
      }
    })
  }

  getAllCategory(page: number, limit: number) {
    this.categoryService.getAllCategory(page, limit).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.categories = response.data.slice(0, 5);
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching category: ', error)
      }
    })
  }

  getProductsByOccasion(occasionId: number): Product[] {
    if (this.occasionProductsMap[occasionId]) {
      return this.occasionProductsMap[occasionId];
    }

    // Gọi API lấy sản phẩm theo occasion
    this.productService.getAllProduct('', 0, occasionId, 0, 4).subscribe({
      next: (response: ApiResponse) => {
        const products = response.data.productResponses.map((p: Product) => {
          p.thumbnailUrl = `${environment.apiBaseUrl}/products/images/${p.thumbnail}`;
          return p;
        });
        this.occasionProductsMap[occasionId] = products;
      },
      error: (err) => {
        console.error(`Lỗi tải sản phẩm cho occasion ${occasionId}:`, err);
        this.occasionProductsMap[occasionId] = [];
      }
    });

    // Trả về mảng rỗng tạm thời
    return this.occasionProductsMap[occasionId] || [];
  }

  getProductsByCategory(categoryId: number): Product[] {
    if (this.categoryProductsMap[categoryId]) {
      return this.categoryProductsMap[categoryId];
    }

    // Gọi API lấy sản phẩm theo occasion
    this.productService.getAllProduct('', categoryId, 0, 0, 4).subscribe({
      next: (response: ApiResponse) => {
        const products = response.data.productResponses.map((p: Product) => {
          p.thumbnailUrl = `${environment.apiBaseUrl}/products/images/${p.thumbnail}`;
          return p;
        });
        this.categoryProductsMap[categoryId] = products;
      },
      error: (err) => {
        console.error(`Lỗi tải sản phẩm cho occasion ${categoryId}:`, err);
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
    event.stopPropagation();

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
