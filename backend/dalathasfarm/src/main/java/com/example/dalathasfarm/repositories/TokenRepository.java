package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Token;
import com.example.dalathasfarm.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TokenRepository extends JpaRepository<Token, Integer> {
    List<Token> findByUser(User user);
    Token findByToken(String token);
    Token findByRefreshToken(String refreshToken);
}
