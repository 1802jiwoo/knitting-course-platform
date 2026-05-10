package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record LectureCreateRequest(
    @NotBlank @Size(max = 100) String title,
    @NotBlank @Size(max = 2000) String description,
    @NotNull String lectureType,
    @Size(max = 10) List<String> tagNames
) {}
