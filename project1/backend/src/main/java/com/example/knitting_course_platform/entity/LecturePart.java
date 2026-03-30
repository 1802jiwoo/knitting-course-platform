package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "LECTURE_PART")
@Getter
@NoArgsConstructor
public class LecturePart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "part_id")
    private Long partId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lecture_id", nullable = false)
    private Lecture lecture;

    @Column(nullable = false)
    private String title;

    @Column(name = "order_no", nullable = false)
    private Integer orderNo;

    @OneToOne(mappedBy = "lecturePart", cascade = CascadeType.ALL)
    private Video video;

    @OneToMany(mappedBy = "lecturePart", cascade = CascadeType.ALL)
    @OrderBy("row_num ASC")  // DB 컬럼명 기준
    private List<PartPattern> partPatterns = new ArrayList<>();
}
