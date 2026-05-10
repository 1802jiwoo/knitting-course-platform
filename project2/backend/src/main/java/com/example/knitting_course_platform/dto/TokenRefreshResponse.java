package com.example.knitting_course_platform.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class TokenRefreshResponse {
    private String accessToken;
    private String refreshToken;
}
