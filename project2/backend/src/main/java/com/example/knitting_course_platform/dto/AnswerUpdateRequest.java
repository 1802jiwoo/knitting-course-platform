package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AnswerUpdateRequest(
    @NotBlank(message = "답변 내용을 입력해 주세요")
    @Size(max = 2000)
    String content
) {}
