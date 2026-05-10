package com.example.knitting_course_platform.dto;

import jakarta.validation.constraints.Size;
import java.util.List;

public record LectureUpdateRequest(
    @Size(max = 100) String title,
    @Size(max = 2000) String description,
    String lectureType,
    @Size(max = 10) List<String> tagNames
) {}
