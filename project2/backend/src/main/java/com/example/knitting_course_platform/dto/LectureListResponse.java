package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Lecture;
import java.util.List;

/// GET /api/lectures 응답 DTO
public record LectureListResponse(
    Long lectureId,
    String title,
    String instructor,
    String lectureType,
    String thumbnailUrl,
    Long enrollmentCount,
    List<String> tags
) {
    public static LectureListResponse from(Lecture lecture, long enrollmentCount) {
        List<String> tagNames = lecture.getLectureTags().stream()
            .map(lt -> lt.getTag().getTagName())
            .toList();

        return new LectureListResponse(
            lecture.getLectureId(),
            lecture.getTitle(),
            lecture.getUser().getNickname(),
            lecture.getLectureType(),
            lecture.getThumbnailUrl(),
            enrollmentCount,
            tagNames
        );
    }
}
