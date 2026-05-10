package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/// POST /api/questions 요청 DTO
public record QuestionCreateRequest(
    @NotNull Long lectureId,
    Long userId,
    @NotBlank @Size(max = 100) String title,
    @NotBlank @Size(max = 1000) String content
) {}
