package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.LecturePattern;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LecturePatternRepository extends JpaRepository<LecturePattern, Long> {
    List<LecturePattern> findByLectureLectureIdOrderByRowNumAsc(Long lectureId);
}
