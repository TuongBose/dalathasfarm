import { Component, OnInit } from '@angular/core';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { ApiResponse } from '../../responses/api.response';
import { FormsModule } from '@angular/forms';
import { Product } from '../../models/product';
import { environment } from '../../environments/environment';
import { BaseComponent } from '../base/base.component';
import { HttpErrorResponse } from '@angular/common/http';

@Component({
  selector: 'app-product-search',
  standalone: true,
  templateUrl: './product-search.component.html',
  styleUrl: './product-search.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
  ]
})
export class ProductSearchComponent extends BaseComponent implements OnInit {
  products: Product[] = [];
  currentPage: number = 0;
  itemsPerPage: number = 12;
  pages: number[] = [];
  totalPages: number = 0;
  visiblePages: number[] = [];
  keyword: string = "";
  selectedCategoryId: number = 0;
  selectedOccasionId: number = 0;
  isPressAddToCart: boolean = false;

  ngOnInit(): void {
    this.activatedRoute.queryParams.subscribe(params => {
      const keyword = params['keyword'] || '';
      if (keyword) {
        this.keyword = keyword;
        this.currentPage = 0;
        this.getAllProduct(this.keyword, this.selectedCategoryId, this.selectedOccasionId, this.currentPage, this.itemsPerPage);
      }
    });
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

  addToCart(
    event: Event,
    productId: number,
    productStockQuantity: number,
    productName: string
  ): void {
    event.stopPropagation();
    debugger

    this.isPressAddToCart = true;
    if (!productId) {
      console.error("Sản phẩm không tồn tại");
      return;
    } else {
      console.error("Không thể thêm sản phẩm vào giỏ hàng vì San Phẩm là Null.");
    }

    const currentQuantityInCart = this.cartService.getQuantityInCart(productId);
    const totalQuantity = currentQuantityInCart + 1;

    if (totalQuantity > productStockQuantity) {
      this.toastService.showToast({
        defaultMsg: `Sản phẩm "${productName}" không đủ hàng trong kho (Còn ${productStockQuantity} sản phẩm). Hiện tại bạn đã có ${currentQuantityInCart} trong giỏ.`,
        title: 'Thông báo',
        delay: 5000,
        type: 'danger'
      });
      return;
    } else {
      this.cartService.addToCart(productId, 1);
      this.toastService.showToast({
        defaultMsg: 'Thêm vào giỏ hàng thành công',
        title: 'Thông báo',
        delay: 3000,
        type: 'success'
      });
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
