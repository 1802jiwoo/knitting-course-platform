package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.Min;

public record PartPatternUpdateRequest(
    @Min(0) Integer startTime,
    @Min(0) Integer endTime,
    String patternText
) {}
