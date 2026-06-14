package com.example.knitting_course_platform.config;

import com.example.knitting_course_platform.filter.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.header.writers.XXssProtectionHeaderWriter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .headers(headers -> headers
                .contentTypeOptions(Customizer.withDefaults())
                .frameOptions(frame -> frame.deny())
                .xssProtection(xss -> xss.headerValue(XXssProtectionHeaderWriter.HeaderValue.ENABLED_MODE_BLOCK))
            )
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // 관리자 전용
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                // 인증 필요 — 기존
                .requestMatchers("/api/auth/logout", "/api/profile/**", "/api/instructor-applications/**", "/api/enrollments/**", "/api/payments/**").authenticated()
                // 인증 필요 — 강의 관리 (강사)
                .requestMatchers(HttpMethod.GET, "/api/lectures/my").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/lectures").authenticated()
                .requestMatchers(HttpMethod.PATCH, "/api/lectures/*").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/lectures/*").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/lectures/*/submit").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/lectures/*/parts").authenticated()
                .requestMatchers(HttpMethod.PATCH, "/api/lectures/*/parts/reorder").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/lectures/*/patterns").authenticated()
                .requestMatchers(HttpMethod.PATCH, "/api/lectures/*/patterns/*").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/lectures/*/patterns/*").authenticated()
                // 인증 필요 — 파트 관리 (강사)
                .requestMatchers(HttpMethod.PATCH, "/api/parts/*").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/parts/*").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/parts/*/patterns").authenticated()
                .requestMatchers(HttpMethod.PATCH, "/api/parts/*/patterns/*").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/parts/*/patterns/*").authenticated()
                // 인증 필요 — 답변 관리 (강사)
                .requestMatchers(HttpMethod.POST, "/api/questions/*/answer").authenticated()
                .requestMatchers(HttpMethod.PATCH, "/api/answers/*").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/answers/*").authenticated()
                .anyRequest().permitAll()
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((req, res, e) -> {
                    res.setStatus(401);
                    res.setContentType("application/json;charset=UTF-8");
                    res.getWriter().write("{\"message\":\"로그인이 필요합니다\"}");
                })
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
