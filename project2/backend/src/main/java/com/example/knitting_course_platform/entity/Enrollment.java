package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "ENROLLMENT", indexes = {
    @Index(name = "idx_enrollment_user_lecture", columnList = "user_id, lecture_id", unique = true),
    @Index(name = "idx_enrollment_user_created", columnList = "user_id, created_at")
})
@Getter
@NoArgsConstructor
public class Enrollment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "enrollment_id")
    private Long enrollmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lecture_id", nullable = false)
    private Lecture lecture;

    @Column(nullable = false)
    private Integer progress = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public static Enrollment create(User user, Lecture lecture) {
        Enrollment e = new Enrollment();
        e.user = user;
        e.lecture = lecture;
        e.progress = 0;
        return e;
    }
}
