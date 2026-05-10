package com.example.knitting_course_platform.dto;

import java.time.LocalDateTime;

public record EnrollmentCreateResponse(Long enrollmentId, Long lectureId, LocalDateTime enrolledAt) {}
