package com.example.knitting_course_platform.dto;

import java.time.LocalDateTime;
import java.util.List;

public record EnrollmentSummaryResponse(
    Long enrollmentId,
    Long lectureId,
    String lectureTitle,
    String instructorName,
    String lectureType,
    String thumbnailUrl,
    List<String> tags,
    List<Long> completedPartIds,
    int totalParts,
    double progress,
    LocalDateTime enrolledAt
) {}
