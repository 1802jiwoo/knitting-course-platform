package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Question;
import java.time.LocalDateTime;

/// GET /api/lectures/{lectureId}/questions 응답 DTO
public record QuestionListResponse(
    Long questionId,
    String title,
    String nickname,
    String imageUrl,
    LocalDateTime createdAt
) {
    public static QuestionListResponse from(Question q) {
        return new QuestionListResponse(
            q.getQuestionId(),
            q.getTitle(),
            q.getUser().getNickname(),
            q.getImageUrl(),
            q.getCreatedAt()
        );
    }
}
