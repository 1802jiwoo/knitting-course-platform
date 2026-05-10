package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ProfileUpdateRequest {

    @Size(min = 2, max = 20, message = "닉네임은 2자 이상 20자 이하여야 합니다")
    @Pattern(regexp = "^[a-zA-Z0-9가-힣]+$", message = "닉네임에 특수문자를 사용할 수 없습니다")
    private String nickname;

    @Size(max = 500, message = "자기소개는 500자 이하여야 합니다")
    private String bio;
}
