package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.Date;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserDto {
    @NotBlank(message = "Password không được bỏ trống")
    private String password;

    @NotBlank(message = "Nhập lại mật khẩu không được bỏ trống")
    private String retypePassword;

    @NotBlank(message = "Họ tên không được bỏ trống")
    private String fullName;

    private String address;

    @NotBlank(message = "Số điện thoại không được bỏ trống")
    @Size(min = 10, max = 10, message = "Số điện thoại phải đủ 10 số")
    private String phoneNumber;

    private String email;
    private Date dateOfBirth;
    private String profileImage;
}
