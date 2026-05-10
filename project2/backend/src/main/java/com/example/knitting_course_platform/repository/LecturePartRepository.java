package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.LecturePart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface LecturePartRepository extends JpaRepository<LecturePart, Long> {

    List<LecturePart> findByLectureLectureIdOrderByOrderNoAsc(Long lectureId);

    @Query("SELECT COALESCE(MAX(p.orderNo), 0) FROM LecturePart p WHERE p.lecture.lectureId = :lectureId")
    int findMaxOrderNoByLectureId(@Param("lectureId") Long lectureId);

    @Query("SELECT COUNT(p) FROM LecturePart p WHERE p.lecture.lectureId = :lectureId")
    long countByLectureId(@Param("lectureId") Long lectureId);
}
