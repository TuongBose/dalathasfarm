// src/app/login/login.component.ts
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BaseComponent } from '../base/base.component';
import { HttpErrorResponse } from '@angular/common/http';
import { UserResponse } from '../../responses/user/user.response';
import { CommonModule } from '@angular/common';
import { ApiResponse } from '../../responses/api.response';
import { catchError, finalize, Observable, of, switchMap, tap, throwError } from 'rxjs';
import { LoginDto } from '../../dtos/user/login.dto';

@Component({
  selector: 'app-login',
  standalone: true,
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
  imports: [CommonModule, FormsModule]
})

export class LoginComponent extends BaseComponent {
  phoneNumber: string = '';
  password: string = '';
  rememberMe: boolean = false;

  userResponse?: UserResponse
  showPassword: boolean = false;

  phoneError: string = '';
  passwordError: string = '';
  fullNameError: string = '';

  validatePhoneNumber() {
    const phone = this.phoneNumber
    if (!phone) {
      this.phoneError = 'Vui lòng nhập số điện thoại';
    } else if (!/^\d{10}$/.test(phone)) {
      this.phoneError = 'Số điện thoại phải đúng 10 chữ số';
    } else {
      this.phoneError = '';
    }
  }

  login() {
    this.validatePhoneNumber();
    if (!this.password) {
      this.passwordError = 'Vui lòng nhập mật khẩu';
    } else {
      this.passwordError = '';
    }

    if (this.phoneError || this.passwordError) {
      return;
    }

    const tryLoginWithRole = (roleId: number): Observable<ApiResponse | null> => {
      const loginDto: LoginDto = {
        password: this.password,
        phoneNumber: this.phoneNumber,
        roleId: roleId,
      };

      return this.userService.login(loginDto).pipe(
        catchError((error: HttpErrorResponse) => {
          // Nếu lỗi 404 hoặc message liên quan đến role → coi như "không tìm thấy user với role này"
          if (error.status === 404 ||
            (error.error?.message && error.error.message.toLowerCase().includes('role'))) {
            return of(null); // Trả về null → thử role khác
          }
          // Các lỗi khác (mật khẩu sai, server error...) → throw để báo người dùng
          return throwError(() => error);
        })
      );
    };

    tryLoginWithRole(1).pipe(
    switchMap((response1) => {
      if (response1) {
        return of(response1); // Thành công với role 1
      }
      // Thử role 2
      return tryLoginWithRole(2);
    }),
    switchMap((finalResponse) => {
      if (!finalResponse) {
        // Cả 2 role đều không tìm thấy user
        throw new HttpErrorResponse({
          error: { message: 'Số điện thoại hoặc mật khẩu không đúng' },
          status: 401
        });
      }
      const { token } = finalResponse.data;
      this.tokenService.setToken(token, this.rememberMe);
    return this.userService.getUserDetails(token).pipe(
        tap((apiResponse2: ApiResponse) => {
          this.userResponse = {
            ...apiResponse2.data,
            dateOfBirth: new Date(apiResponse2.data.dateOfBirth),
          };
          this.userService.saveUserToLocalStorage(this.userResponse, this.rememberMe);
        })
      );
    }),
    finalize(() => {
      this.cartService.refreshCart();
    })
  ).subscribe({
    next: () => {
      this.toastService.showToast({
        defaultMsg: 'Đăng nhập thành công',
        title: 'Thông báo',
        delay: 3000,
        type: 'success'
      });
      setTimeout(() => {
        this.resetFormLogin();
        this.router.navigate(['/']);
      }, 2000);
    },
    error: (error: HttpErrorResponse) => {
      this.toastService.showToast({
        defaultMsg: 'Số điện thoại hoặc mật khẩu không đúng',
        title: 'Lỗi đăng nhập',
        delay: 3000,
        type: 'danger'
      });
    }
  });
}

  resetFormLogin() {
    this.phoneNumber = '';
    this.password = '';
  }
}