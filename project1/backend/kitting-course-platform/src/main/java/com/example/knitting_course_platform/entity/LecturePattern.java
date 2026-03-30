package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "LECTURE_PATTERN")
@Getter
@NoArgsConstructor
public class LecturePattern {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "pattern_id")
    private Long patternId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lecture_id", nullable = false)
    private Lecture lecture;

    @Column(name = "row_num", nullable = false)
    private Integer rowNum;

    @Column(name = "pattern_text", columnDefinition = "TEXT", nullable = false)
    private String patternText;
}
