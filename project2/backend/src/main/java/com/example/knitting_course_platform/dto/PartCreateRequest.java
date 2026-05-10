package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PartCreateRequest(
    @NotBlank @Size(max = 100) String title,
    String youtubeUrl,
    Integer duration
) {}
