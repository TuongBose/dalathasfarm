package com.example.dalathasfarm.services.Token;

import com.example.dalathasfarm.models.Token;
import com.example.dalathasfarm.models.User;

public interface ITokenService {
    Token addToken(User user, String token, Boolean isMobileDevice);
    Token refreshToken (String refreshToken, User user) throws Exception;
}
