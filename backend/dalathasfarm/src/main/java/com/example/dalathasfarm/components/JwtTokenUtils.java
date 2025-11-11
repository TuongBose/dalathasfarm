package com.example.dalathasfarm.components;

import com.example.dalathasfarm.models.Token;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.repositories.TokenRepository;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.io.Encoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.InvalidParameterException;
import java.security.Key;
import java.security.SecureRandom;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
@RequiredArgsConstructor
public class JwtTokenUtils {
    private final TokenRepository tokenRepository;
    private static final Logger logger = LoggerFactory.getLogger(JwtTokenUtils.class);

    @Value("${jwt.expiration}")
    private Long expiration; // Save to an environment variable
    @Value("${jwt.secretKey}")
    private String secretKey;

    private Key getSignInKey() {
        byte[] bytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(bytes);
    }

    public String generateToken(User user) throws Exception {
        // properties => claims
        Map<String, Object> claims = new HashMap<>();
        // Add subject identifier (phone number)
        String subject = getSubject(user);
        claims.put("subject", subject);
        // Add user ID
        claims.put("userId", user.getId());
        try {
            return Jwts
                    .builder()
                    .setClaims(claims)
                    .setSubject(subject)
                    .setExpiration(new Date(System.currentTimeMillis() + expiration * 1000L))
                    .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                    .compact();
        } catch (Exception e) {
            // Có thể dùng Logger, instead System.out.println
            throw new InvalidParameterException("Can not create jwt token, error: " + e.getMessage());
        }
    }

    // Get all claims
    private Claims extractAllClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // Get one claim
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = this.extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // Check expiration
    public boolean isTokenExpired(String token) {
        Date expirationDate = this.extractClaim(token, Claims::getExpiration);
        return expirationDate.before(new Date());
    }

    public String extractPhoneNumber(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public boolean validateToken(String token, User userDetails) {
        try {
            String subject = extractClaim(token, Claims::getSubject);
            // subject is phonenumber or email
            Token existingToken = tokenRepository.findByToken(token);
            if (existingToken == null || existingToken.getRevoked() || !userDetails.getIsActive()) {
                return false;
            }
            return (subject.equals(userDetails.getUsername())) && !isTokenExpired(token);
        } catch (MalformedJwtException e) {
            logger.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            logger.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            logger.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("JWT claims string is empty: {}", e.getMessage());
        }

        return false;
    }

//    private static String getSubject(Account account) {
//        // Determine subject identifier (phone number or email)
//        String subject = account.getSODIENTHOAI();
//        if (subject == null || subject.isBlank()) {
//            // If phone number is null or blank, use email as subject
//            subject = account.getEMAIL();
//        }
//        return subject;
//    }

    private static String getSubject(User user) {
        // Determine subject identifier (phone number or email)
        if (user.getPhoneNumber() != null && !user.getPhoneNumber().isBlank()) {
            return user.getPhoneNumber();
        }
        return null;
    }

    private String generateSecretKey() {
        SecureRandom random = new SecureRandom();
        byte[] keyBytes = new byte[32]; // 256-bit key
        random.nextBytes(keyBytes);
        return Encoders.BASE64.encode(keyBytes);
    }

    public String getSubject(String token) {
        return extractClaim(token, Claims::getSubject);
    }
}
