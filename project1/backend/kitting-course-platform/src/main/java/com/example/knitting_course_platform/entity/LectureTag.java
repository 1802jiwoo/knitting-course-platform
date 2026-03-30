package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "LECTURE_TAG")
@Getter
@NoArgsConstructor
public class LectureTag {

    // DB의 LECTURE_TAG 테이블은 (lecture_id, tag_id) 복합키
    // 별도 id 컬럼이 없으므로 @IdClass 또는 @EmbeddedId 사용
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
}
