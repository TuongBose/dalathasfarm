package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.Date;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserDto {
    @NotBlank(message = "Password khong duoc bo trong")
    private String password;
    private String retypePassword;
    private String fullName;
    private String address;
    private String phoneNumber;
    private String email;
    private Date dateOfBirth;
    private String profileImage;
}
