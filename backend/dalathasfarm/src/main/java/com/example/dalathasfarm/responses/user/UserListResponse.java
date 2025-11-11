package com.example.dalathasfarm.responses.user;

import lombok.*;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserListResponse {
    private List<UserResponse> userResponseList;
    private int totalPages;
}
