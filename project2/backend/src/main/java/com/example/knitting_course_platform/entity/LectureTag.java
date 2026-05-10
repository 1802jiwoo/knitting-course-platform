package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "LECTURE_TAG")
@Getter
@NoArgsConstructor
public class LectureTag {

    @EmbeddedId
    private LectureTagId id = new LectureTagId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("lectureId")
    @JoinColumn(name = "lecture_id", nullable = false)
    private Lecture lecture;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("tagId")
    @JoinColumn(name = "tag_id", nullable = false)
    private Tag tag;

    public static LectureTag create(Lecture lecture, Tag tag) {
        LectureTag lt = new LectureTag();
        lt.lecture = lecture;
        lt.tag = tag;
        return lt;
    }
}
