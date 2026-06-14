package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    boolean existsByUserIdAndLectureId(Long userId, Long lectureId);
    List<Payment> findAllByUserIdOrderByCreatedAtDesc(Long userId);
}
