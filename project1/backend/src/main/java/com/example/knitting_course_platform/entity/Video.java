package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "VIDEO")
@Getter
@NoArgsConstructor
public class Video {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "video_id")
    private Long videoId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "part_id", nullable = false)
    private LecturePart lecturePart;

    @Column(name = "youtube_url", nullable = false)
    private String youtubeUrl;

    @Column(nullable = false)
    private Integer duration;
}
