import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { NgbActiveModal, NgbNavModule } from '@ng-bootstrap/ng-bootstrap';
import { UserResponse } from '../../responses/user/user.response';
import { BaseComponent } from '../base/base.component';
import { LoginDto } from '../../dtos/user/login.dto';
import { ApiResponse } from '../../responses/api.response';
import { HttpErrorResponse } from '@angular/common/http';
import { catchError, delay, finalize, of, switchMap, tap } from 'rxjs';
import { RegisterDto } from '../../dtos/user/register.dto';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-auth-modal',
  standalone: true,
  imports: [CommonModule, FormsModule, NgbNavModule],
  templateUrl: './auth-modal.component.html',
  styleUrl: './auth-modal.component.css',
})
export class AuthModalComponent extends BaseComponent {
  phoneNumber: string = '';
  password: string = '';
  rememberMe: boolean = false;

  retypePassword: string = '';
  phoneNumberRegister: string = '';
  passwordRegister: string = '';
  fullName: string = '';

  userResponse?: UserResponse
  showPassword: boolean = false;
  isSignIn = true;

  phoneError: string = '';
  passwordError: string = '';
  retypePasswordError: string = '';
  fullNameError: string = '';

  constructor(public activeModal: NgbActiveModal) { super() }

  validatePhoneNumber() {
    const phone = this.isSignIn ? this.phoneNumber : this.phoneNumberRegister;
    if (!phone) {
      this.phoneError = 'Vui lòng nhập số điện thoại';
    } else if (!/^\d{10}$/.test(phone)) {
      this.phoneError = 'Số điện thoại phải đúng 10 chữ số';
    } else {
      this.phoneError = '';
    }
  }

  validatePassword() {
    if (!this.passwordRegister) {
      this.passwordError = 'Vui lòng nhập mật khẩu';
    } else if (this.passwordRegister.length < 6) {
      this.passwordError = 'Mật khẩu phải từ 6 ký tự trở lên';
    } else {
      this.passwordError = '';
    }
    this.validatePasswordMatch(); // Gọi lại để kiểm tra khớp
  }

  validateRetypePassword() {
    if (!this.retypePassword) {
      this.retypePasswordError = 'Vui lòng nhập lại mật khẩu';
    } else {
      this.retypePasswordError = '';
    }
    this.validatePasswordMatch();
  }

  validatePasswordMatch() {
    if (this.passwordRegister && this.retypePassword) {
      if (this.passwordRegister !== this.retypePassword) {
        this.retypePasswordError = 'Mật khẩu nhập lại không khớp';
      } else if (this.retypePasswordError === 'Mật khẩu nhập lại không khớp') {
        this.retypePasswordError = '';
      }
    }
  }

  validateFullName() {
    if (!this.fullName.trim()) {
      this.fullNameError = 'Vui lòng nhập họ và tên';
    } else {
      this.fullNameError = '';
    }
  }

  switchToSignUp() {
    this.isSignIn = false;
  }

  switchToSignIn() {
    this.isSignIn = true;
  }

  register() {
    this.validateFullName();
    this.validatePhoneNumber();
    this.validatePassword();
    this.validateRetypePassword();

    if (this.fullNameError || this.phoneError || this.passwordError || this.retypePasswordError) {
      return;
    }

    const registerDto: RegisterDto = {
      "password": this.passwordRegister,
      "retypePassword": this.retypePassword,
      "email": '',
      "fullName": this.fullName,
      "address": '',
      "phoneNumber": this.phoneNumberRegister,
      "dateOfBirth": new Date(),
    }
    debugger
    this.userService.register(registerDto).subscribe({
      next: (apiResponse: ApiResponse) => {
        this.toastService.showToast({
          defaultMsg: 'Đăng ký thành công',
          title: 'Thông báo',
          delay: 3000,
          type: 'success'
        });
        this.isSignIn = true;
        this.resetFormRegister();
      },
      complete: () => { debugger },
      error: (error: HttpErrorResponse) => {
        this.toastService.showToast({
          error: error,
          defaultMsg: 'Lỗi không xác định',
          title: 'Lỗi Đăng Ký'
        });
      }
    });
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
        this.activeModal.dismiss();
        setTimeout(() => {
          this.resetFormLogin();
          window.location.reload();
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

  resetFormRegister() {
    this.phoneNumberRegister = '';
    this.fullName = '';
    this.passwordRegister = '';
    this.retypePassword = '';
  }
}
