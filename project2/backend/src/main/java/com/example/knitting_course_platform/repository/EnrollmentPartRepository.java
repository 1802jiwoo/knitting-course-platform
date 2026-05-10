package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.EnrollmentPart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface EnrollmentPartRepository extends JpaRepository<EnrollmentPart, Long> {

    boolean existsByEnrollment_EnrollmentIdAndPartId(Long enrollmentId, Long partId);

    @Query("SELECT ep.partId FROM EnrollmentPart ep WHERE ep.enrollment.enrollmentId = :enrollmentId")
    List<Long> findPartIdsByEnrollmentId(@Param("enrollmentId") Long enrollmentId);
}
