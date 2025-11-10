package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Token;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TokenRepository extends JpaRepository<Integer, Token> {
}
