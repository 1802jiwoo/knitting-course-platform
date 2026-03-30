package com.example.knitting_course_platform.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Embeddable
@NoArgsConstructor
@EqualsAndHashCode
public class LectureTagId implements Serializable {

    @Column(name = "lecture_id")
    private Long lectureId;

    @Column(name = "tag_id")
    private Long tagId;
}
