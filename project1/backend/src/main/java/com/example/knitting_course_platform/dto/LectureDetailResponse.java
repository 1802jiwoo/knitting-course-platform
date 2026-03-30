package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Lecture;
import java.util.List;

/// GET /api/lectures/{lectureId} 응답 DTO
public record LectureDetailResponse(
    Long lectureId,
    String title,
    String description,
    String instructor,
    String lectureType,
    List<String> tags
) {
    public static LectureDetailResponse from(Lecture lecture) {
        List<String> tagNames = lecture.getLectureTags().stream()
            .map(lt -> lt.getTag().getTagName())
            .toList();

        return new LectureDetailResponse(
            lecture.getLectureId(),
            lecture.getTitle(),
            lecture.getDescription(),
            lecture.getUser().getNickname(),
            lecture.getLectureType(),
            tagNames
        );
    }
}
