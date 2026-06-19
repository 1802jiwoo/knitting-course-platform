package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Lecture;

import java.time.LocalDateTime;

public record AdminLectureResponse(
        Long lectureId,
        String title,
        String lectureType,
        String status,
        Long instructorUserId,
        String instructorNickname,
        LocalDateTime createdAt
) {
    public static AdminLectureResponse from(Lecture lecture) {
        return new AdminLectureResponse(
                lecture.getLectureId(),
                lecture.getTitle(),
                lecture.getLectureType(),
                lecture.getStatus(),
                lecture.getUser().getUserId(),
                lecture.getUser().getNickname(),
                lecture.getCreatedAt()
        );
    }
}
