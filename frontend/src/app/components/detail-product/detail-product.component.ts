import { Component, OnInit } from '@angular/core';
import { environment } from '../../environments/environment';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { BaseComponent } from '../base/base.component';
import { ApiResponse } from '../../responses/api.response';
import { FeedbackResponse } from '../../responses/feedback.response';
import { FormsModule } from '@angular/forms';
import { Product } from '../../models/product';
import { UserResponse } from '../../responses/user/user.response';
import { FeedbackDto } from '../../dtos/feedback.dto';
import { ProductImage } from '../../models/product.image';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Component({
  selector: 'app-detail-product',
  standalone: true,
  templateUrl: './detail-product.component.html',
  styleUrl: './detail-product.component.scss',
  imports: [
    CommonModule,
    HeaderComponent,
    FooterComponent,
    NgbModule,
    FormsModule
  ]
})
export class DetailProductComponent extends BaseComponent implements OnInit {
  product?: Product;
  productId: number = 0;
  currentImageIndex: number = 0;
  quantity: number = 1;
  user?: UserResponse | null;
  isPressAddToCart: boolean = false;
  feedbackResponse: FeedbackResponse[] = [];
  isAddingFeedback: boolean = false;
  feedbackError: string | null = null;
  hoveredStar: number = 0;
  newFeedback: FeedbackDto = {
    userId: 0,
    content: '',
    star: 0,
    productId: 0
  };
  isLoading: boolean = true;
  componentsHtml: SafeHtml = '';

  averageRating = 0;
  totalReviews = 0;
  recommendPercent = 0;
  starDistribution: { [key: number]: number } = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
  reviewImages: string[] = [];
  isReviewModalOpen = false;

  constructor(private sanitizer: DomSanitizer) { super() }

  ngOnInit(): void {
    debugger
    this.activatedRoute.paramMap.subscribe(params => {
      const idParam = params.get('id');
      if (idParam !== null) {
        this.productId = +idParam; // Chuyển đổi sang số
      } else {
        console.error('Cannot find product');
        this.router.navigate(['/']); // Điều hướng về trang chủ nếu không có tham số
        return;
      }

      if (!isNaN(this.productId)) {
        this.isLoading = true;
        this.productService.getProductById(this.productId).subscribe({
          next: (apiResponse: ApiResponse) => {
            const response = apiResponse.data;
            debugger
            if (response.productImageResponses && response.productImageResponses.length > 0) {
              response.productImageResponses.forEach((productImage: ProductImage) => {
                productImage.imageUrl = `${environment.apiBaseUrl}/products/images/${productImage.name}`;
              });
            }
            this.product = response
            this.product!.productImages = response.productImageResponses;
            this.showImage(0);
            this.componentsHtml = this.sanitizer.bypassSecurityTrustHtml(response.components);
          },
          complete: () => {
            debugger;
            this.isLoading = false;
          },
          error: (error: any) => {
            debugger;
            console.error('Error fetching detail: ', error);
            this.product = undefined;
          }
        });

        this.loadFeedbacks();
      }
      else {
        console.error('Invalid productId: ', idParam)
      }
    });
  }

  showImage(index: number): void {
    debugger
    if (this.product && this.product.productImages && this.product.productImages.length > 0) {
      const total = this.product.productImages.length;

      if (index < 0) {
        index = total - 1;
      } else if (index >= this.product.productImages.length) {
        index = 0;
      }

      //Gán index hiện tại và cập nhật ảnh hiển thị
      this.currentImageIndex = index;
    }
  }

  thumbnailClick(index: number) {
    debugger
    this.currentImageIndex = index;
  }

  nextImage(): void {
    debugger
    this.showImage(this.currentImageIndex + 1);
  }

  previousImage(): void {
    debugger
    this.showImage(this.currentImageIndex - 1)
  }

  addToCart(): void {
    debugger
    const token = this.tokenService.getToken();
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.isPressAddToCart = true;
    if (this.product) {
      this.cartService.addToCart(this.product.id, this.quantity);
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

  increaseQuantity(): void {
    debugger;
    if (this.quantity < this.product!.stockQuantity) {
      this.quantity++;
    }
    else {
      this.toastService.showToast({
        defaultMsg: 'Đã đạt giới hạn kho',
        title: 'Thông báo',
        delay: 3000,
        type: 'danger'
      });
    }
  }

  decreaseQuantity(): void {
    if (this.quantity > 1) {
      this.quantity--;
    }
  }

  buyNow(): void {
    this.user = this.userService.getUserFromLocalStorage();
    if (this.user == null) {
      this.router.navigate(['/login']);
    }
    else {
      if (this.isPressAddToCart == false) {
        this.addToCart();
      }
      this.router.navigate(['/orders']);
    }
  }

  getTotalPrice(): number {
    if (this.product) {
      return this.product.price * this.quantity;
    }
    return 0;
  }

  openReviewModal() {
    this.isReviewModalOpen = true;
    this.newFeedback = { star: 0, content: '', userId: 0, productId: this.productId };
    this.feedbackError = null;
  }

  closeReviewModal() {
    this.isReviewModalOpen = false;
  }

  submitFeedback(): void {
    this.user = this.userService.getUserFromLocalStorage();
    if (this.user == null) {
      this.router.navigate(['/login']);
      return;
    }

    const token = this.tokenService.getToken();
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    const feedbackDTO: FeedbackDto = {
      userId: this.user?.id,
      productId: this.productId,
      star: this.newFeedback.star,
      content: this.newFeedback.content
    }

    this.isAddingFeedback = true;
    this.feedbackError = null;

    this.feedbackService.insertFeedback(feedbackDTO).subscribe({
      next: () => {
        this.newFeedback = {
          userId: 0,
          content: '',
          star: 0,
          productId: 0
        }; // Reset form
        this.loadFeedbacks(); // Cập nhật danh sách feedback
        this.closeReviewModal();
        this.hoveredStar = 0;
      },
      error: (error) => {
        this.feedbackError = 'Failed to submit feedback. Please try again.';
        this.toastService.showToast({
          defaultMsg: 'Đánh giá thất bại',
          title: 'Thông báo',
          delay: 3000,
          type: 'danger'
        });
      },
      complete: () => {
        this.isAddingFeedback = false;
        this.toastService.showToast({
          defaultMsg: 'Đánh giá thành công',
          title: 'Thông báo',
          delay: 3000,
          type: 'success'
        });
      }
    });
  }

  loadFeedbacks(): void {
    this.feedbackService.getFeedbacksByProductId(this.productId).subscribe({
      next: (apiResponse: ApiResponse) => {
        debugger
        this.feedbackResponse = apiResponse.data as FeedbackResponse[];
        this.calculateStats();
      },
      error: (error: any) => {
        console.error('Error fetching feedbacks: ', error);
      }
    });
  }

  calculateStats() {
    if (!this.feedbackResponse.length) return;

    this.totalReviews = this.feedbackResponse.length;
    const sum = this.feedbackResponse.reduce((acc, f) => acc + f.star, 0);
    this.averageRating = Number((sum / this.totalReviews).toFixed(1));

    // Đếm sao
    this.feedbackResponse.forEach(f => {
      this.starDistribution[f.star]++;
    });

    // % recommend (giả sử star >= 4 là recommend)
    const recommendCount = this.feedbackResponse.filter(f => f.star >= 4).length;
    this.recommendPercent = Math.round((recommendCount / this.totalReviews) * 100);
  }

  getStarWidth(star: number): string {
    const count = this.starDistribution[star];
    return this.totalReviews ? `${(count / this.totalReviews) * 100}%` : '0%';
  }

  onStarHover(value: number): void {
    this.hoveredStar = value;
  }

  onStarLeave(): void { this.hoveredStar = 0; }

  onStarClick(value: number): void {
    this.newFeedback.star = value;
  }

  getStarArray(star: number): number[] {
    const rounded = Math.round(star)
    return Array(rounded).fill(0).map((_, index) => index + 1);
  }
}
