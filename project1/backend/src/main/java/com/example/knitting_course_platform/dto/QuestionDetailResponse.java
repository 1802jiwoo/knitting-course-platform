package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Question;
import java.time.LocalDateTime;

/// GET /api/questions/{questionId} 응답 DTO
public record QuestionDetailResponse(
    Long questionId,
    Long lectureId,
    String nickname,
    String title,
    String content,
    String imageUrl,
    LocalDateTime createdAt
) {
    public static QuestionDetailResponse from(Question q) {
        return new QuestionDetailResponse(
            q.getQuestionId(),
            q.getLecture().getLectureId(),
            q.getUser().getNickname(),
            q.getTitle(),
            q.getContent(),
            q.getImageUrl(),
            q.getCreatedAt()
        );
    }
}
