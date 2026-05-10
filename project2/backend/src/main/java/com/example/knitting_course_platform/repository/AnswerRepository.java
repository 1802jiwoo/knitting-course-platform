package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Answer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AnswerRepository extends JpaRepository<Answer, Long> {
    List<Answer> findAllByQuestion_QuestionIdOrderByCreatedAtAsc(Long questionId);
}