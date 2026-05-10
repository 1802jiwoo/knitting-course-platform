package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class TokenRefreshRequest {

    @NotBlank
    private String refreshToken;
}
