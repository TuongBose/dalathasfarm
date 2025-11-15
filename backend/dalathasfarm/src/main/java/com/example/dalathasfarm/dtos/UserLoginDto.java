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
    private String password;
}
