package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserLoginDto {
    @NotBlank(message = "Số điện thoại không được bỏ trống")
    @Size(min = 10, max = 10, message = "Số điện thoại phải đủ 10 số")
    private String phoneNumber;

    @NotBlank(message = "Mật khẩu không được bỏ trống")
    @Size(min = 6, max = 50, message = "Password phải từ 6 đến 50 ký tự")
    private String password;

    @NotBlank(message = "Mật khẩu không được bỏ trống")
    @Size(min = 1, max = 1, message = "Vai trò phải đủ 1 số")
    private Integer roleId;
}
