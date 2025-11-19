package com.example.dalathasfarm.responses.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LoginResponse {
    @JsonProperty("message")
    private String message;

    @JsonProperty("token")
    private String token;

    private String tokenType;
    private String refreshToken;
    private String userName;
    private List<String> role;
    private Integer id;
}
