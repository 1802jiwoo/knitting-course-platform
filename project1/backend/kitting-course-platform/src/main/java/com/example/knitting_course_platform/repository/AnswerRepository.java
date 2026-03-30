package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Answer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AnswerRepository extends JpaRepository<Answer, Long> {
    Optional<Answer> findByQuestion_QuestionId(Long questionId);
}