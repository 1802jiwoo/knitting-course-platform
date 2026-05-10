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

    public static Video create(LecturePart part, String youtubeUrl, Integer duration) {
        Video v = new Video();
        v.lecturePart = part;
        v.youtubeUrl = youtubeUrl;
        v.duration = duration != null ? duration : 0;
        return v;
    }

    public void update(String youtubeUrl, Integer duration) {
        if (youtubeUrl != null) this.youtubeUrl = youtubeUrl;
        if (duration != null) this.duration = duration;
    }
}
