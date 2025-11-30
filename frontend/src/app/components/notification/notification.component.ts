import { Component, DOCUMENT, inject, OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NotificationResponse } from "../../responses/notification.response";
import { HeaderComponent } from "../header/header.component";
import { FooterComponent } from "../footer/footer.component";
import { BaseComponent } from "../base/base.component";
import { AuthModalComponent } from "../auth-modal/auth-modal.component";
import { NgbModal } from "@ng-bootstrap/ng-bootstrap";

@Component({
  selector: 'app-notification',
  standalone: true,
  templateUrl: './notification.component.html',
  styleUrl: './notification.component.css',
  imports: [
    CommonModule,
    HeaderComponent,
    FooterComponent
  ]
})

export class NotificationComponent extends BaseComponent implements OnInit {
  notifications: NotificationResponse[] = [];
  account?: number | null;

  constructor(private modalService: NgbModal){super()}

  ngOnInit(): void {
    debugger
    this.account = this.userService.getUserFromLocalStorage()?.id;
    if (this.account) {
      this.loadNotifications();
    }
  }

  // Tải danh sách thông báo
  private loadNotifications(): void {
    debugger
    if (this.account) {
      this.notificationService.getNotificationByUserId().subscribe({
        next: (data: any) => {
          debugger
          this.notifications = data.data as NotificationResponse[];
          this.updateUnreadCount();
        },
        error: (err) => {
          console.error('Lỗi khi tải thông báo:', err);
        }
      });
    }
  }

  // Đánh dấu thông báo là đã đọc
  markAsRead(notificationId: number): void {
    debugger
    this.notificationService.markAsRead(notificationId).subscribe({
      next: () => {
        debugger
        this.notifications = this.notifications.map(notification =>
          notification.notification_id === notificationId ? { ...notification, isRead: true } : notification
        );
        this.loadNotifications();
        this.updateUnreadCount();
        this.toastService.showToast({
          defaultMsg: 'Đã đánh dấu đọc',
          title: 'Thông báo',
          delay: 3000,
          type: 'success'
        });
      },
      error: (err) => {
        console.error('Lỗi khi đánh dấu thông báo là đã đọc:', err);
      }
    });
  }

  markAllAsRead(): void {
    if (this.account && this.notifications.length > 0) {
      const unreadNotifications = this.notifications.filter(n => !n.is_read).map(n => n.notification_id);
      if (unreadNotifications.length === 0) {
        this.toastService.showToast({
          defaultMsg: 'Không có thông báo nào để đánh dấu đọc',
          title: 'Thông báo',
          delay: 3000,
          type: 'info'
        });
        return;
      }

      this.notificationService.markAllAsRead().subscribe({
        next: () => {
          this.loadNotifications(); 
          this.updateUnreadCount();
          this.toastService.showToast({
            defaultMsg: 'Đã đánh dấu tất cả là đã đọc',
            title: 'Thông báo',
            delay: 3000,
            type: 'success'
          });
        },
        error: (err) => {
          console.error('Lỗi khi đánh dấu tất cả là đã đọc:', err);
          this.toastService.showToast({
            defaultMsg: 'Đã xảy ra lỗi khi đánh dấu tất cả',
            title: 'Lỗi',
            delay: 3000,
            type: 'danger'
          });
        }
      });
    }
  }

  private updateUnreadCount(): void {
    const unreadCount = this.notifications.filter(n => !n.is_read).length;
    this.notificationService.updateUnreadCount(unreadCount); // Cập nhật qua service
  }

  openAuthModal() {
      this.modalService.open(AuthModalComponent, {
        centered: true,
        size: 'md',
        windowClass: 'auth-modal-window'
      });
    }
}