package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.LecturePart;
import com.example.knitting_course_platform.entity.Video;

/// GET /api/lectures/{lectureId}/parts 응답 DTO
/// API 명세: order (DB: order_no), duration 단위: 초
public record LecturePartResponse(
    Long partId,
    String title,
    Integer order,
    String youtubeUrl,
    Integer duration
) {
    public static LecturePartResponse from(LecturePart part) {
        Video video = part.getVideo();
        return new LecturePartResponse(
            part.getPartId(),
            part.getTitle(),
            part.getOrderNo(),
            video != null ? video.getYoutubeUrl() : null,
            video != null ? video.getDuration() : null
        );
    }
}
