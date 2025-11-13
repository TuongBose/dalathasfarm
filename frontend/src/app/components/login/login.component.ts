import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { FormsModule, NgForm } from '@angular/forms';
import { HeaderComponent } from '../header/header.component';
import { FooterComponent } from '../footer/footer.component';
import { CommonModule } from '@angular/common';
import { BaseComponent } from '../base/base.component';
import { HttpErrorResponse } from '@angular/common/http';
import { catchError, finalize, of, switchMap, tap } from 'rxjs';
import { ApiResponse } from '../../responses/api.response';
import { UserResponse } from '../../responses/user/user.response';
import { LoginDto } from '../../dtos/user/login.dto';

@Component({
  selector: 'app-login',
  standalone: true,
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
  imports: [
    HeaderComponent,
    FooterComponent,
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class LoginComponent extends BaseComponent {
  @ViewChild('loginForm') loginForm!: NgForm;

  phoneNumber: string = '';
  password: string = '';
  rememberMe: boolean = false;
  userResponse?: UserResponse
  showPassword: boolean = false;

  createAccount() {
    debugger
    // Chuyển hướng người dùng đến trang đăng ký (hoặc trang tạo tài khoản)
    this.router.navigate(['/register']);
  }

  login() {
    const loginDto: LoginDto = {
      password: this.password,
      phoneNumber: this.phoneNumber,
    }
    this.userService.login(loginDto).pipe(
      tap((apiResponse: ApiResponse) => {
        const { token } = apiResponse.data;
        this.tokenService.setToken(token);
      }),
      switchMap((apiResponse: ApiResponse) => {
        const { token } = apiResponse.data;
        return this.userService.getUserDetails(token).pipe(
          tap((apiResponse2: ApiResponse) => {
            this.userService = {
              ...apiResponse2.data,
              ngaysinh: new Date(apiResponse2.data.ngaysinh),
            };
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
        this.router.navigate(['/']);
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
}
