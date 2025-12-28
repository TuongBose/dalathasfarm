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
import { ChangePasswordDto } from '../../dtos/user/change-password.dto';

@Component({
  selector: 'app-change-password',
  standalone: true,
  templateUrl: './change-password.component.html',
  styleUrl: './change-password.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
  ]

})
export class ChangePasswordComponent extends BaseComponent {
  form: ChangePasswordDto = {
    oldPassword: '',
    newPassword: '',
    retypeNewPassword: ''
  };

  submitted = false;
  isLoading = false;

  changePassword() {
    this.submitted = true;

    if (!this.form.oldPassword || !this.form.newPassword || !this.form.retypeNewPassword) {
      this.toastService.showToast({
        defaultMsg: 'Vui lòng nhập đầy đủ thông tin',
        type: 'warning'
      });
      return;
    }

    if (this.form.newPassword !== this.form.retypeNewPassword) {
      this.toastService.showToast({
        defaultMsg: 'Mật khẩu mới và nhập lại không khớp',
        type: 'danger'
      });
      return;
    }

    if (this.form.newPassword.length < 6) {
      this.toastService.showToast({
        defaultMsg: 'Mật khẩu mới phải có ít nhất 6 ký tự',
        type: 'warning'
      });
      return;
    }

    this.isLoading = true;

    this.userService.changePassword(this.form).subscribe({
      next: () => {
        this.toastService.showToast({
          defaultMsg: 'Đổi mật khẩu thành công! Bạn sẽ được đăng xuất để bảo mật.',
          type: 'success',
          delay: 5000
        });

        setTimeout(() => {
          this.userService.removeUserFromLocalStorage();
          this.tokenService.removeToken();
          this.router.navigate(['']);
        }, 3000);
      },
      error: (err: HttpErrorResponse) => {
        this.isLoading = false;
        const msg = err.error?.message || 'Đổi mật khẩu thất bại. Vui lòng thử lại.';
        this.toastService.showToast({
          defaultMsg: msg,
          type: 'danger'
        });
      }
    });
  }
}
