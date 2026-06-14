package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.List;

public record LectureCreateRequest(
    @NotBlank @Size(max = 100) String title,
    @NotBlank @Size(max = 2000) String description,
    @NotNull @Pattern(regexp = "^(STITCH_BASICS|PROJECT_CLASS|PATTERN)$",
                     message = "lectureType은 STITCH_BASICS, PROJECT_CLASS, PATTERN 중 하나여야 합니다")
    String lectureType,
    @Size(max = 10) List<String> tagNames
) {}
