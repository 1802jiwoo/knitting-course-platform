package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.Size;

public record PartUpdateRequest(
    @Size(max = 100) String title,
    String youtubeUrl,
    Integer duration
) {}
