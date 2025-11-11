package com.example.dalathasfarm.responses.user;

import com.example.dalathasfarm.models.Role;
import com.example.dalathasfarm.models.User;
import lombok.*;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserResponse {
    private int userId;
    private String fullName;
    private String address;
    private String phoneNumber;
    private Date dateOfBirth;
    private String email;
    private boolean isActive;
    private String profileImage;
    private Role roleName;

    public static UserResponse fromUser(User user) {
        return UserResponse
                .builder()
                .userId(user.getId())
                .fullName(user.getFullName())
                .address(user.getAddress())
                .phoneNumber(user.getPhoneNumber())
                .dateOfBirth(user.getDateOfBirth())
                .email(user.getEmail())
                .profileImage(user.getProfileImage())
                .isActive(user.getIsActive())
                .roleName(user.getRole())
                .build();
    }
}
