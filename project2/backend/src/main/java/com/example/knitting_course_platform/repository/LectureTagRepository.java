package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.LectureTag;
import com.example.knitting_course_platform.entity.LectureTagId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface LectureTagRepository extends JpaRepository<LectureTag, LectureTagId> {

    @Modifying
    @Query("DELETE FROM LectureTag lt WHERE lt.lecture.lectureId = :lectureId")
    void deleteByLectureLectureId(@Param("lectureId") Long lectureId);
}
