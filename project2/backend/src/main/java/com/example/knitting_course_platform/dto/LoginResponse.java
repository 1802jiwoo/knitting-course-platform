package com.example.knitting_course_platform.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LoginResponse {
    private Long userId;
    private String nickname;
    private String role;
    private String accessToken;
    private String refreshToken;
}
