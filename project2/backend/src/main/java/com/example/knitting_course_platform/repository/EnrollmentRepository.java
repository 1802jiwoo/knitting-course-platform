package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {

    @Query("SELECT COUNT(e) FROM Enrollment e WHERE e.lecture.lectureId = :lectureId")
    long countByLectureId(@Param("lectureId") Long lectureId);

    boolean existsByUser_UserIdAndLecture_LectureId(Long userId, Long lectureId);

    Optional<Enrollment> findByUser_UserIdAndLecture_LectureId(Long userId, Long lectureId);

    List<Enrollment> findByUser_UserIdOrderByCreatedAtDesc(Long userId);
}
