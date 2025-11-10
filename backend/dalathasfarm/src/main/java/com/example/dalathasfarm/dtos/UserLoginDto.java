package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserLoginDto {
    @NotBlank(message = "Số điện thoại không được bỏ trống")
    private String phoneNumber;

    @NotBlank(message = "Mật khẩu không được bỏ trống")
    private String password;
}
