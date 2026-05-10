package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SignUpRequest {

    @Email
    @NotBlank
    @Size(max = 100)
    private String email;

    @NotBlank
    private String password;

    @NotBlank
    @Size(min = 2, max = 20)
    private String nickname;
}
