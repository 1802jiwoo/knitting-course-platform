package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Video;

/// GET /api/parts/{partId}/video 응답 DTO
public record VideoResponse(
    Long videoId,
    String youtubeUrl,
    Integer duration
) {
    public static VideoResponse from(Video video) {
        return new VideoResponse(
            video.getVideoId(),
            video.getYoutubeUrl(),
            video.getDuration()
        );
    }
}
