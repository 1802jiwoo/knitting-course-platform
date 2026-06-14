package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "instructor_application", indexes = {
    @Index(name = "idx_app_user_status", columnList = "user_id, status"),
    @Index(name = "idx_app_status_created", columnList = "status, created_at")
})
@Getter
@NoArgsConstructor
public class InstructorApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "application_id")
    private Long applicationId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(nullable = false, length = 500)
    private String bio;

    @Column(name = "teaching_plan", nullable = false, length = 1000)
    private String teachingPlan;

    @Column(nullable = false, length = 20)
    private String status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.status = "PENDING";
    }

    public static InstructorApplication create(Long userId, String bio, String teachingPlan) {
        InstructorApplication app = new InstructorApplication();
        app.userId = userId;
        app.bio = bio;
        app.teachingPlan = teachingPlan;
        return app;
    }

    public void approve() {
        this.status = "APPROVED";
    }

    public void reject() {
        this.status = "REJECTED";
    }
}
