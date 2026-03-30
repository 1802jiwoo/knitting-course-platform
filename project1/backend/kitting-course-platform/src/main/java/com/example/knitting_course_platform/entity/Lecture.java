package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "LECTURE")
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
}
