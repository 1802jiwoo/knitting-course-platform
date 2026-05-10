package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findByLectureLectureIdOrderByCreatedAtDesc(Long lectureId);
}
