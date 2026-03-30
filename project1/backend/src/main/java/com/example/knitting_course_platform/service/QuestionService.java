package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.entity.*;
import com.example.knitting_course_platform.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final LectureRepository lectureRepository;
    private final UserRepository userRepository;

    // GET /api/lectures/{lectureId}/questions
    @Transactional(readOnly = true)
    public List<QuestionListResponse> getQuestions(Long lectureId) {
        return questionRepository.findByLectureLectureIdOrderByCreatedAtDesc(lectureId)
                .stream()
                .map(QuestionListResponse::from)
                .toList();
    }

    // GET /api/questions/{questionId}
    @Transactional(readOnly = true)
    public QuestionDetailResponse getQuestionDetail(Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new IllegalArgumentException("질문을 찾을 수 없습니다: " + questionId));
        return QuestionDetailResponse.from(question);
    }

    // POST /api/questions
    public void createQuestion(QuestionCreateRequest request) {
        Lecture lecture = lectureRepository.findById(request.lectureId())
                .orElseThrow(() -> new IllegalArgumentException("강의를 찾을 수 없습니다: " + request.lectureId()));

        Long userId = (request.userId() != null) ? request.userId() : 1L;
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        Question question = Question.builder()
                .lecture(lecture)
                .user(user)
                .title(request.title())
                .content(request.content())
                .build();

        questionRepository.save(question);
    }
}
