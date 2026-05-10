package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.PartPattern;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface PartPatternRepository extends JpaRepository<PartPattern, Long> {
    List<PartPattern> findByLecturePartPartIdOrderByRowNumAsc(Long partId);

    @Query("SELECT COALESCE(MAX(p.rowNum), 0) FROM PartPattern p WHERE p.lecturePart.partId = :partId")
    int findMaxRowNumByPartId(@Param("partId") Long partId);
}
