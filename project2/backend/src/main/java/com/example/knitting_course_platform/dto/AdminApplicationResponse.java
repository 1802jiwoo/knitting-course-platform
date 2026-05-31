package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.InstructorApplication;
import com.example.knitting_course_platform.entity.User;

import java.time.LocalDateTime;

public record AdminApplicationResponse(
        Long applicationId,
        Long userId,
        String nickname,
        String bio,
        String teachingPlan,
        String status,
        LocalDateTime createdAt
) {
    public static AdminApplicationResponse from(InstructorApplication app, User user) {
        return new AdminApplicationResponse(
                app.getApplicationId(),
                app.getUserId(),
                user.getNickname(),
                app.getBio(),
                app.getTeachingPlan(),
                app.getStatus(),
                app.getCreatedAt()
        );
    }
}
