package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;

public record LecturePatternCreateRequest(
    @NotBlank String patternText
) {}
