import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { NgbModal, NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { BaseComponent } from '../base/base.component';
import { environment } from '../../environments/environment';
import { NotificationResponse } from '../../responses/notification.response';
import { ApiResponse } from '../../responses/api.response';
import { UserResponse } from '../../responses/user/user.response';
import { HttpErrorResponse } from '@angular/common/http';
import { Category } from '../../models/category';
import { AuthModalComponent } from '../auth-modal/auth-modal.component';

@Component({
  selector: 'app-header',
  standalone: true,
  templateUrl: './header.component.html',
  styleUrl: './header.component.scss',
  imports: [
    CommonModule,
    NgbModule,
    RouterModule
  ]
})
export class HeaderComponent extends BaseComponent implements OnInit {
  user?: UserResponse | null;
  isPopoverOpen?: boolean;
  cartItemCount: number = 0;
  unreadNotificationCount: number = 0;
  logoUrl?: string;
  logoname: string = 'logo.png';
  currentPage: number = 0;
  itemsPerPage: number = 12;
  categories: Category[] = [];

  activeNavItem: number = 0;
  navItems = [
    { name: 'Trang chủ', route: '/home' },
    { name: 'Thông báo', route: '/notification' },
    { name: 'Đơn hàng', route: '/orders' },
    { name: 'Giới thiệu', route: '/introduce' },
    { name: 'Liên hệ', route: '/contact' },
  ];

  constructor(private modalService: NgbModal) {
    super();
    this.cartService.cartItemCount$.subscribe(count => {
      this.cartItemCount = count;
    });

    this.cartService.cartChanged.subscribe(() => {
      this.cartItemCount = this.cartService.getCartItemCount();
    });
  }

  ngOnInit(): void {
    debugger
    const currentUrl = this.router.url;
    const foundIndex = this.navItems.findIndex(item => currentUrl.startsWith(item.route));
    this.activeNavItem = foundIndex !== -1 ? foundIndex : 0;

    debugger
    this.user = this.userService.getUserFromLocalStorage();
    this.cartItemCount = this.cartService.getCartItemCount();

    if (typeof window !== 'undefined') {
      window.addEventListener('scroll', () => {
        const header = document.querySelector('header');
        if (header) {
          if (window.scrollY > 20) {
            header.classList.add('scrolled');
          } else {
            header.classList.remove('scrolled');
          }
        }
      });
    }

    this.logoUrl = `${environment.apiBaseUrl}/products/images/${this.logoname}`;
    this.loadUnreadNotifications();
    this.notificationService.unreadCount$.subscribe(count => {
      this.unreadNotificationCount = count;
    });

    this.getAllCategory(0, 20);
  }

  openAuthModal() {
    this.modalService.open(AuthModalComponent, {
      centered: true,
      size: 'md',
      windowClass: 'auth-modal-window'
    });
  }

  updateCartCount(): void {
    this.cartItemCount = this.cartService.getCartItemCount();
  }

  togglePopover(event: Event): void {
    event.preventDefault();
    this.isPopoverOpen = !this.isPopoverOpen;
  }

  handleItemClick(index: number): void {
    if (index === 0) {
      debugger
      this.router.navigate(['/user-profile'])
    } else if (index === 2) {
      this.userService.removeUserFromLocalStorage();
      this.tokenService.removeToken()
      this.user = this.userService.getUserFromLocalStorage();
    }
    this.isPopoverOpen = false;
  }

  setActiveNavItem(index: number) {
    this.activeNavItem = index;
  }

  private loadUnreadNotifications(): void {
    debugger
    if (this.user && this.user.id) {
      this.notificationService.getUnreadNotifications().subscribe({
        next: (apiResponse: ApiResponse) => {
          debugger
          this.unreadNotificationCount = (apiResponse.data as NotificationResponse[]).length;
          this.notificationService.updateUnreadCount(this.unreadNotificationCount);
        },
        error: (err) => {
          console.error('Lỗi khi tải số thông báo chưa đọc:', err);
        }
      });
    }
  }

  logout(): void {
    this.userService.removeUserFromLocalStorage();
    this.tokenService.removeToken();
    this.user = null;
  }

  getAllCategory(page: number, limit: number) {
    this.categoryService.getAllCategory(page, limit).subscribe({
      next: (response: ApiResponse) => {
        debugger
        this.categories = response.data.slice(0, 10);
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        debugger;
        console.error('Error fetching category: ', error)
      }
    })
  }
}
