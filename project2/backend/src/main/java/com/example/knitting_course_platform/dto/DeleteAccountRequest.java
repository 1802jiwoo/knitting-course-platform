package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class DeleteAccountRequest {

    @NotBlank
    private String password;
}
