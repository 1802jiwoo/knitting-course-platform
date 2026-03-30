package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.LecturePart;

/// GET /api/lectures/{lectureId}/parts 응답 DTO
/// API 명세: order (DB: order_no)
public record LecturePartResponse(
    Long partId,
    String title,
    Integer order
) {
    public static LecturePartResponse from(LecturePart part) {
        return new LecturePartResponse(
            part.getPartId(),
            part.getTitle(),
            part.getOrderNo()
        );
    }
}
