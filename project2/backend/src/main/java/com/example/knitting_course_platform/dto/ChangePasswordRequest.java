package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ChangePasswordRequest {

    @NotBlank
    private String currentPassword;

    @NotBlank
    private String newPassword;
}
