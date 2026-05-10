package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Lecture;
import java.time.LocalDateTime;
import java.util.List;

public record MyLectureListResponse(
    Long lectureId,
    String title,
    String description,
    String lectureType,
    String status,
    String thumbnailUrl,
    Long enrollmentCount,
    LocalDateTime createdAt,
    List<String> tagNames
) {
    public static MyLectureListResponse from(Lecture lecture, long enrollmentCount) {
        List<String> tags = lecture.getLectureTags().stream()
            .map(lt -> lt.getTag().getTagName())
            .toList();
        return new MyLectureListResponse(
            lecture.getLectureId(),
            lecture.getTitle(),
            lecture.getDescription(),
            lecture.getLectureType(),
            lecture.getStatus(),
            lecture.getThumbnailUrl(),
            enrollmentCount,
            lecture.getCreatedAt(),
            tags
        );
    }
}
