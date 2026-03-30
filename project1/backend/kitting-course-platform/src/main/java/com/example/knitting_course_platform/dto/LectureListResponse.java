package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Lecture;
import java.util.List;

/// GET /api/lectures 응답 DTO
public record LectureListResponse(
    Long lectureId,
    String title,
    String instructor,
    String lectureType,
    List<String> tags
) {
    public static LectureListResponse from(Lecture lecture) {
        List<String> tagNames = lecture.getLectureTags().stream()
            .map(lt -> lt.getTag().getTagName())
            .toList();

        return new LectureListResponse(
            lecture.getLectureId(),
            lecture.getTitle(),
            lecture.getUser().getNickname(),
            lecture.getLectureType(),
            tagNames
        );
    }
}
