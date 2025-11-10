package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotBlank;

import java.util.Date;

public class UserDto {
    @NotBlank(message = "Password khong duoc bo trong")
    private String password;
    private String retypePassword;
    private String fullName;
    private String address;
    private String phoneNumber;
    private Date dateOfBirth;
}
