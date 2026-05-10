package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record PartPatternCreateRequest(
    @NotNull @Min(0) Integer startTime,
    @NotNull @Min(0) Integer endTime,
    @NotBlank String patternText
) {}
