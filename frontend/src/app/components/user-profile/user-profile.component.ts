import { Component, inject, OnInit } from '@angular/core';
import { HeaderComponent } from "../header/header.component";
import { FooterComponent } from "../footer/footer.component";
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { BaseComponent } from '../base/base.component';
import { HttpErrorResponse } from '@angular/common/http';
import { UserResponse } from '../../responses/user/user.response';
import { UpdateUserDto } from '../../dtos/user/update.user.dto';

@Component({
  selector: 'app-user-profile',
  imports: [HeaderComponent, FooterComponent, ReactiveFormsModule, FormsModule, CommonModule],
  templateUrl: './user-profile.component.html',
  styleUrl: './user-profile.component.scss',
  standalone: true
})
export class UserProfileComponent extends BaseComponent implements OnInit {
  userResponse?: UserResponse;
  token: string = '';
  userProfileForm!: FormGroup;

  constructor(
    private fb: FormBuilder,
  ) {
    super();
    this.userProfileForm = this.fb.group({
      fullname: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      sodienthoai: ['', [Validators.required, Validators.pattern('^[0-9]{10}$')]],
      diachi: [''],
      ngaysinh: [''],
      ghichu: [''],
      password: [''],
      retypePassword: ['']
    });
  }

  ngOnInit(): void {
    this.token = this.tokenService.getToken() ?? '';
    if (!this.token) {
      alert('Bạn chưa đăng nhập!');
      this.router.navigate(['/login']);
      return;
    }

    const userStr = localStorage.getItem('user') || sessionStorage.getItem('user');
    if (!userStr) {
      alert('Không tìm thấy thông tin tài khoản trong localStorage!');
      this.router.navigate(['/login']);
      return;
    }

    try {
      this.userResponse = JSON.parse(userStr) as UserResponse;
      this.userProfileForm.patchValue({
        fullname: this.userResponse.fullName || '',
        email: this.userResponse.email || '',
        sodienthoai: this.userResponse.phoneNumber || '',
        diachi: this.userResponse.address || '',
        ngaysinh: this.userResponse.dateOfBirth || '',
      });
    } catch (error) {
      console.error('Lỗi khi parse user từ localStorage:', error);
      alert('Không thể xử lý thông tin tài khoản.');
    }

    // Kiểm tra mật khẩu khớp
    this.userProfileForm.get('retypePassword')?.valueChanges.subscribe(value => {
      const password = this.userProfileForm.get('password')?.value;
      if (password && value && password !== value) {
        this.userProfileForm.get('retypePassword')?.setErrors({ mismatch: true });
      } else {
        this.userProfileForm.get('retypePassword')?.setErrors(null);
      }
    });
  }

  save(): void {
    if (this.userProfileForm.valid) {
      const updateUserDto: UpdateUserDto = {
        fullName: this.userProfileForm.get('fullname')?.value,
        address: this.userProfileForm.get('diachi')?.value, // Sử dụng diachi thay vì address
        password: this.userProfileForm.get('password')?.value,
        retypePassword: this.userProfileForm.get('retypePassword')?.value,
        dateOfBirth: this.userProfileForm.get('ngaysinh')?.value // Sử dụng ngaysinh thay vì date_of_birth
      };

      this.userService.updateUserDetail(this.token, updateUserDto)
        .subscribe({
          next: (response: any) => {
            this.userService.removeUserFromLocalStorage();
            this.tokenService.removeToken();
            this.router.navigate(['/login']);
          },
          error: (error: HttpErrorResponse) => {
            console.error(error?.error?.message ?? '');
          }
        });
    } else {
      if (this.userProfileForm.get('retypePassword')?.hasError('mismatch')) {
        console.error('Mật khẩu và mật khẩu gõ lại chưa chính xác');
      }
      console.log('Form invalid');
    }
  }
}