package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Answer;

import java.time.LocalDateTime;

public record AnswerDetailResponse(
        Long answerId,
        String content,
        String nickname,
        LocalDateTime createdAt
) {
    public static AnswerDetailResponse from(Answer answer) {
        return new AnswerDetailResponse(
                answer.getAnswerId(),
                answer.getContent(),
                answer.getUser().getNickname(),
                answer.getCreatedAt()
        );
    }
}