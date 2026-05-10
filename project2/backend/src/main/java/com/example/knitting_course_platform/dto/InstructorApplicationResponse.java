package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.InstructorApplication;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class InstructorApplicationResponse {

    private final Long applicationId;
    private final String bio;
    private final String teachingPlan;
    private final String status;
    private final LocalDateTime createdAt;

    public InstructorApplicationResponse(InstructorApplication app) {
        this.applicationId = app.getApplicationId();
        this.bio = app.getBio();
        this.teachingPlan = app.getTeachingPlan();
        this.status = app.getStatus();
        this.createdAt = app.getCreatedAt();
    }
}
