package com.example.knitting_course_platform.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SignUpResult {
    private Long userId;
    private String email;
    private String nickname;
    private String role;
}
