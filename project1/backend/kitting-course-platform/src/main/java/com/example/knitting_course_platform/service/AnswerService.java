package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.AnswerDetailResponse;
import com.example.knitting_course_platform.entity.Answer;
import com.example.knitting_course_platform.repository.AnswerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AnswerService {

    private final AnswerRepository answerRepository;

    @Transactional(readOnly = true)
    public AnswerDetailResponse getAnswer(Long questionId) {
        Answer answer = answerRepository.findByQuestion_QuestionId(questionId)
                .orElseThrow(() -> new IllegalArgumentException("답변을 찾을 수 없습니다."));
        return AnswerDetailResponse.from(answer);
    }
}