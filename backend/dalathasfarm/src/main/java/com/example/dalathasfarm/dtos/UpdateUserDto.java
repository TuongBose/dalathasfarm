package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.time.LocalDate;
import java.util.Date;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UpdateUserDto {
    @NotBlank(message = "Password không được bỏ trống")
    private String password;
    private String retypePassword;
    private String email;
    private String fullName;
    private String address;

    @NotBlank(message = "Số điện thoại không được bỏ trống")
    private String phoneNumber;

    private LocalDate dateOfBirth;
}
