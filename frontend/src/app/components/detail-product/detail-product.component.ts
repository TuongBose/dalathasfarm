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
            this.showImage(0);
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
      if (index < 0) {
        index = 0;
      } else if (index >= this.product.productImages.length) {
        index = this.product.productImages.length - 1;
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
    if (this.quantity < this.product!.stock_quantity) {
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
      },
      error: (error: any) => {
        console.error('Error fetching feedbacks: ', error);
      }
    });
  }

  onStarHover(value: number): void {
    this.hoveredStar = value;
  }

  onStarLeave(): void { this.hoveredStar = 0; }

  onStarClick(value: number): void {
    this.newFeedback.star = value;
  }

  getStarArray(sosao: number): number[] {
    return Array(sosao).fill(0).map((_, index) => index + 1);
  }
}
