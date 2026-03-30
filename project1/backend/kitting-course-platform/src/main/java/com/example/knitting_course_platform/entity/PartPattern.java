package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "PART_PATTERN")
@Getter
@NoArgsConstructor
public class PartPattern {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "pattern_id")
    private Long patternId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "part_id", nullable = false)
    private LecturePart lecturePart;

    @Column(name = "start_time", nullable = false)
    private Integer startTime;

    @Column(name = "end_time", nullable = false)
    private Integer endTime;

    @Column(name = "row_num", nullable = false)
    private Integer rowNum;

    @Column(name = "pattern_text", columnDefinition = "TEXT", nullable = false)
    private String patternText;
}
