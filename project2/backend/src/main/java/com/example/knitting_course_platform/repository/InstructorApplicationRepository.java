package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.InstructorApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface InstructorApplicationRepository extends JpaRepository<InstructorApplication, Long> {

    boolean existsByUserIdAndStatus(Long userId, String status);

    Optional<InstructorApplication> findByUserIdAndStatus(Long userId, String status);
}
