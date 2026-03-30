package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.PartPattern;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PartPatternRepository extends JpaRepository<PartPattern, Long> {
    List<PartPattern> findByLecturePartPartIdOrderByRowNumAsc(Long partId);
}
