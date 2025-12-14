// src/app/login/login.component.ts
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BaseComponent } from '../base/base.component';
import { HttpErrorResponse } from '@angular/common/http';
import { UserResponse } from '../../responses/user/user.response';
import { CommonModule } from '@angular/common';
import { ApiResponse } from '../../responses/api.response';
import { catchError, finalize, of, switchMap, tap } from 'rxjs';
import { LoginDto } from '../../dtos/user/login.dto';

@Component({
  selector: 'app-login',
  standalone: true,
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
  imports:[CommonModule, FormsModule]
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

    const loginDto: LoginDto = {
      password: this.password,
      phoneNumber: this.phoneNumber,
      roleId:1,
    }
    this.userService.login(loginDto).pipe(
      tap((apiResponse: ApiResponse) => {
        const { token } = apiResponse.data;
        this.tokenService.setToken(token,this.rememberMe);
      }),
      switchMap((apiResponse: ApiResponse) => {
        const { token } = apiResponse.data;
        return this.userService.getUserDetails(token).pipe(
          tap((apiResponse2: ApiResponse) => {
            this.userResponse = {
              ...apiResponse2.data,
              dateOfBirth: new Date(apiResponse2.data.dateOfBirth),
            };
            debugger
            this.userService.saveUserToLocalStorage(this.userResponse, this.rememberMe);
          }),
          catchError((error: HttpErrorResponse) => {
            console.error('Lỗi khi lấy thông tin người dùng:', error?.error?.message ?? '');
            return of(null); // Tiếp tục chuỗi Observable
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
          error,
          defaultMsg: 'Đăng nhập thất bại!',
          title: 'Lỗi đăng nhập',
          delay: 3000,
          type: 'danger'
        });
        console.error('Lỗi đăng nhập:', error?.error?.message ?? '');
      }
    });
  }

  resetFormLogin() {
    this.phoneNumber = '';
    this.password = '';
  }
}