package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.LoginRequest;
import com.example.knitting_course_platform.dto.LoginResponse;
import com.example.knitting_course_platform.dto.SignUpRequest;
import com.example.knitting_course_platform.dto.SignUpResult;
import com.example.knitting_course_platform.dto.TokenRefreshRequest;
import com.example.knitting_course_platform.dto.TokenRefreshResponse;
import com.example.knitting_course_platform.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    @ResponseStatus(HttpStatus.CREATED)
    public SignUpResult signUp(@Valid @RequestBody SignUpRequest request) {
        return authService.signUp(request);
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        authService.logout(userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    public TokenRefreshResponse refresh(@Valid @RequestBody TokenRefreshRequest request) {
        return authService.refresh(request);
    }
}
