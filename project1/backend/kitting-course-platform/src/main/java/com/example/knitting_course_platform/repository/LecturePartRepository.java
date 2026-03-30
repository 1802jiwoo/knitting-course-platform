package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.LecturePart;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LecturePartRepository extends JpaRepository<LecturePart, Long> {
    List<LecturePart> findByLectureLectureIdOrderByOrderNoAsc(Long lectureId);
}
