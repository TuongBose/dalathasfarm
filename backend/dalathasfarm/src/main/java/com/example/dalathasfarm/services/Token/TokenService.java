package com.example.dalathasfarm.services.Token;

import com.example.dalathasfarm.components.JwtTokenUtils;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.exceptions.ExpiredTokenException;
import com.example.dalathasfarm.models.Token;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.repositories.TokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TokenService implements ITokenService{
    private final TokenRepository tokenRepository;
    private final JwtTokenUtils jwtTokenUtils;

    @Value("${jwt.expiration}")
    private int expiration;

    @Value("${jwt.expiration-refresh-token}")
    private int expirationRefreshToken;

    @Override
    public Token addToken(User user, String token, Boolean isMobileDevice) {
        List<Token> userTokens = tokenRepository.findByUser(user);
        int tokenCount = userTokens.size();
        // If count over limit, delete one token old
        if (tokenCount >= Token.MAX_TOKENS) {
            // Kiem tra xem trong danh sach userTokens co ton tai it nhat
            // mot token khong phai la thiet bi di dong (non-mobile)
            boolean hasNonMobileToken = !userTokens.stream().allMatch(Token::getIsMobile);
            Token tokenToDelete;
            if (hasNonMobileToken) {
                tokenToDelete = userTokens.stream()
                        .filter(accountToken -> !accountToken.getIsMobile())
                        .findFirst()
                        .orElse(userTokens.getFirst());
            } else {
                // Tat ca cac token deu la thiet bi di dong, chung ta se xoa token dau tien trong danh sach
                tokenToDelete = userTokens.getFirst();
            }
            tokenRepository.delete(tokenToDelete);
        }

        LocalDateTime expirationDateTime = LocalDateTime.now().plusSeconds(expiration);
        // Create new token for account
        Token newToken = Token.builder()
                .user(user)
                .token(token)
                .revoked(false)
                .expired(false)
                .tokenType("Bearer")
                .expirationDate(expirationDateTime)
                .isMobile(isMobileDevice)
                .build();
        newToken.setRefreshToken(UUID.randomUUID().toString());
        newToken.setRefreshExpirationDate(LocalDateTime.now().plusSeconds(expirationRefreshToken));
        tokenRepository.save(newToken);
        return newToken;
    }

    @Override
    public Token refreshToken(String refreshToken, User user) throws Exception {
        Token existingToken = tokenRepository.findByRefreshToken(refreshToken);
        if (existingToken == null) {
            throw new DataNotFoundException("Refresh token does not exist");
        }
        if (existingToken.getRefreshExpirationDate().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(existingToken);
            throw new ExpiredTokenException("Refresh token is expired");
        }

        String token = jwtTokenUtils.generateToken(user); // Return token
        LocalDateTime expirationDateTime = LocalDateTime.now().plusSeconds(expiration);

        existingToken.setToken(token);
        existingToken.setExpirationDate(expirationDateTime);
        existingToken.setRefreshToken(UUID.randomUUID().toString());
        existingToken.setRefreshExpirationDate(LocalDateTime.now().plusSeconds(expirationRefreshToken));

        tokenRepository.save(existingToken);
        return existingToken;
    }
}
