package com.example.dalathasfarm.filters;

import com.example.dalathasfarm.components.JwtTokenUtils;
import com.example.dalathasfarm.models.User;
import jakarta.annotation.Nonnull;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.util.Pair;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
@RequiredArgsConstructor
public class JwtTokenFilter extends OncePerRequestFilter {
    private final UserDetailsService userDetailsService;
    private final JwtTokenUtils jwtTokenUtils;

    @Value("${api.prefix}")
    private String apiPrefix;

    @Override
    protected void doFilterInternal(@Nonnull HttpServletRequest request,
                                    @Nonnull HttpServletResponse response,
                                    @Nonnull FilterChain filterChain)
            throws ServletException, IOException {
        try {
            final String authHeader = request.getHeader("Authorization");
            String requestPath = request.getServletPath();
            String requestMethod = request.getMethod();

            if (requestPath.equals(String.format("%s/orders", apiPrefix))
                    && requestMethod.equals("POST")) {
                if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                    filterChain.doFilter(request, response);
                    return;
                }
            }

            if (isBypassToken(request)) {
                filterChain.doFilter(request, response); //enable bypass
                return;
            }

            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
                return;
            }

            final String token = authHeader.substring(7);
            final String phoneNumber = jwtTokenUtils.getSubject(token);

            if (phoneNumber != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                User userDetails = (User) userDetailsService.loadUserByUsername(phoneNumber);
                if (jwtTokenUtils.validateToken(token, userDetails)) {
                    UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );
                    authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authenticationToken);
                }
            }

            filterChain.doFilter(request, response); //enable bypass
        } catch (Exception e) {
            //response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(e.getMessage());
        }
    }

    private boolean isBypassToken(@Nonnull HttpServletRequest request) {
        final List<Pair<String, String>> bypassTokens = Arrays.asList(
                Pair.of(String.format("%s/products**", apiPrefix), "GET"),
                Pair.of(String.format("%s/categories**", apiPrefix), "GET"),
                Pair.of(String.format("%s/occasions**", apiPrefix), "GET"),
                Pair.of(String.format("%s/users/auth**", apiPrefix), "GET"),
                Pair.of(String.format("%s/users/register", apiPrefix), "POST"),
                Pair.of(String.format("%s/users/register/admin", apiPrefix), "POST"),
                Pair.of(String.format("%s/users/login", apiPrefix), "POST"),
                Pair.of(String.format("%s/users/refreshToken", apiPrefix), "POST"),

//                Pair.of(String.format("%s/orders**", apiPrefix), "POST"),

                // Healthcheck, khong yeu cau JWT token
                Pair.of(String.format("%s/healthcheck/health", apiPrefix), "GET"),
                Pair.of(String.format("%s/actuator**", apiPrefix), "GET"),

                // feedback
                Pair.of(String.format("%s/feedbacks**", apiPrefix), "GET"),

                // coupon
                Pair.of(String.format("%s/coupons**", apiPrefix), "GET"),

                // policy
                Pair.of(String.format("%s/policies**", apiPrefix), "GET")

        );

        String requestPath = request.getServletPath();
        String requestMethod = request.getMethod();

        if (requestPath.startsWith(String.format("%s/orders", apiPrefix))
                && requestMethod.equals("GET")) {
            // Check if the requestPath matches the desired pattern
            if (requestPath.matches(String.format("%s/orders/\\d+", apiPrefix))) {
                return true;
            }
            // If the requestPath is just "api/v1/orders", return true
            if (requestPath.equals(String.format("%s/orders", apiPrefix))) {
                return true;
            }
        }

        for (Pair<String, String> bypassToken : bypassTokens) {
            String tokenPath = bypassToken.getFirst();
            String tokenMethod = bypassToken.getSecond();
            // Check if the token  path contains a wildcard character
            if (tokenPath.contains("**")) {
                // Replace "**" with a regular expression capturing any characters
                String regexPath = tokenPath.replace("**", ".*");
                // Create a pattern to match the request path
                Pattern pattern = Pattern.compile(regexPath);
                Matcher matcher = pattern.matcher(requestPath);

                // Check if the request path matches the pattern and the request method matches the token method
                if (matcher.matches() && requestMethod.equals(tokenMethod)) {
                    return true;
                }
            } else if (requestPath.equals(tokenPath) && requestMethod.equals(tokenMethod)) {
                return true;
            }
        }
        return false;
    }
}
