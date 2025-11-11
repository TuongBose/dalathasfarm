package com.example.dalathasfarm.configurations;

import com.example.dalathasfarm.filters.JwtTokenFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.actuate.autoconfigure.security.servlet.EndpointRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.CorsConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

import static org.springframework.http.HttpMethod.*;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
@EnableGlobalMethodSecurity(prePostEnabled = true)
//@EnableWebMvc
public class WebSecurityConfig {
    private final JwtTokenFilter jwtTokenFilter;

    @Value("${api.prefix}")
    private String apiPrefix;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
                //.addFilterBefore(jwtTokenFilter, UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(customizer->customizer.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
                .sessionManagement(c->c.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(requests -> {
                    requests.requestMatchers(
                                    String.format("%s/users/register", apiPrefix),
                                    String.format("%s/users/login", apiPrefix),
                                    String.format("%s/users/refreshToken", apiPrefix),
                                    String.format("%s/healthcheck/**", apiPrefix),
                                    String.format("%s/actuator/**", apiPrefix)                            
                            ).permitAll()
                            //.requestMatchers("**").permitAll()

                            // feedbacks
                            .requestMatchers(GET,String.format("%s/feedbacks/**",apiPrefix)).permitAll()

                            // coupons
                            .requestMatchers(GET,String.format("%s/coupons/**",apiPrefix)).permitAll()

                            // categories
//                            .requestMatchers(GET, String.format("%s/categories/**", apiPrefix)).permitAll()
//                            .requestMatchers(POST, String.format("%s/categories/**", apiPrefix)).hasRole(Role.ADMIN)
//                            .requestMatchers(PUT, String.format("%s/categories/**", apiPrefix)).hasRole(Role.ADMIN)
//                            .requestMatchers(DELETE, String.format("%s/categories/**", apiPrefix)).hasRole(Role.ADMIN)
//
//                            // products
//                            .requestMatchers(GET, String.format("%s/products/**", apiPrefix)).permitAll()
//                            .requestMatchers(GET, String.format("%s/products/images/**", apiPrefix)).permitAll()
//                            .requestMatchers(POST, String.format("%s/products/**", apiPrefix)).hasRole(Role.ADMIN)
//                            .requestMatchers(PUT, String.format("%s/products/**", apiPrefix)).hasRole(Role.ADMIN)
//                            .requestMatchers(DELETE, String.format("%s/products/**", apiPrefix)).hasRole(Role.ADMIN)
//
//                            // orders
//                            .requestMatchers(POST, String.format("%s/orders/**", apiPrefix)).hasAnyRole(Role.USER, Role.ADMIN)
//                            .requestMatchers(DELETE, String.format("%s/orders/**", apiPrefix)).hasRole(Role.ADMIN)
//
//                            /*
//                             If you comment this, you must add @PreAuthorize("hasRole('ROLE_ADMIN')") at controller
//                            .requestMatchers(GET, String.format("%s/orders/get-alldonhang-by-keyword",apiPrefix)).hasRole(Role.ADMIN)
//                            */
//
//                            .requestMatchers(GET, String.format("%s/orders/**", apiPrefix)).permitAll()
//                            .requestMatchers(PUT, String.format("%s/orders/status", apiPrefix)).hasRole(Role.ADMIN)
//
//                            // order_details
//                            .requestMatchers(PUT, String.format("%s/order_details/**", apiPrefix)).hasAnyRole(Role.USER, Role.ADMIN)
//                            .requestMatchers(POST, String.format("%s/order_details/**", apiPrefix)).hasAnyRole(Role.USER, Role.ADMIN)
//                            .requestMatchers(DELETE, String.format("%s/order_details/**", apiPrefix)).hasRole(Role.ADMIN)
//                            .requestMatchers(GET, String.format("%s/order_details/**", apiPrefix)).hasAnyRole(Role.USER, Role.ADMIN)

                            .anyRequest().authenticated();
                })

                .csrf(AbstractHttpConfigurer::disable)
                .cors(new Customizer<CorsConfigurer<HttpSecurity>>() {
                    @Override
                    public void customize(CorsConfigurer<HttpSecurity> httpSecurityCorsConfigurer) {
                        CorsConfiguration configuration = new CorsConfiguration();
                        configuration.setAllowedOrigins(List.of("*"));
                        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
                        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
                        configuration.setExposedHeaders(List.of("x-auth-token"));
                        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                        source.registerCorsConfiguration("/**", configuration);
                        httpSecurityCorsConfigurer.configurationSource(source);
                    }
                })
                .securityMatcher(String.valueOf(EndpointRequest.toAnyEndpoint()))
                .build();
    }
}
