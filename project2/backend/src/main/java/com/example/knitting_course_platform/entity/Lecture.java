package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "LECTURE", indexes = {
    @Index(name = "idx_lecture_status", columnList = "status")
})
@Getter
@NoArgsConstructor
public class Lecture {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "lecture_id")
    private Long lectureId;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "lecture_type", nullable = false)
    private String lectureType;

    @Column(nullable = false)
    private String status = "DRAFT";

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    @Column(nullable = false)
    private int price = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "lecture", cascade = CascadeType.ALL)
    @OrderBy("orderNo ASC")
    private List<LecturePart> parts = new ArrayList<>();

    @OneToMany(mappedBy = "lecture", cascade = CascadeType.ALL)
    private List<LectureTag> lectureTags = new ArrayList<>();

    @OneToMany(mappedBy = "lecture", cascade = CascadeType.ALL)
    @OrderBy("rowNum ASC")
    private List<LecturePattern> lecturePatterns = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public static Lecture create(User user, String title, String description, String lectureType, String thumbnailUrl) {
        Lecture l = new Lecture();
        l.user = user;
        l.title = title;
        l.description = description;
        l.lectureType = lectureType;
        l.thumbnailUrl = thumbnailUrl;
        l.status = "DRAFT";
        return l;
    }

    public void update(String title, String description, String lectureType, String thumbnailUrl) {
        if (title != null) this.title = title;
        if (description != null) this.description = description;
        if (lectureType != null) this.lectureType = lectureType;
        if (thumbnailUrl != null) this.thumbnailUrl = thumbnailUrl;
        if ("APPROVED".equals(this.status)) this.status = "DRAFT";
    }

    public void submit() {
        this.status = "PENDING";
    }

    public void revertToDraft() {
        this.status = "DRAFT";
    }

    public boolean isOwnedBy(Long userId) {
        return this.user.getUserId().equals(userId);
    }

    public boolean isDeletable() {
        return "DRAFT".equals(this.status) || "REJECTED".equals(this.status);
    }

    public boolean isEditable() {
        return !"PENDING".equals(this.status) && !"HIDDEN".equals(this.status);
    }
}
