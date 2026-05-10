package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.LecturePattern;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface LecturePatternRepository extends JpaRepository<LecturePattern, Long> {
    List<LecturePattern> findByLectureLectureIdOrderByRowNumAsc(Long lectureId);

    @Query("SELECT COALESCE(MAX(p.rowNum), 0) FROM LecturePattern p WHERE p.lecture.lectureId = :lectureId")
    int findMaxRowNumByLectureId(@Param("lectureId") Long lectureId);
}
