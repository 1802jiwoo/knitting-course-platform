package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.AnswerCreateRequest;
import com.example.knitting_course_platform.dto.AnswerDetailResponse;
import com.example.knitting_course_platform.dto.AnswerUpdateRequest;
import com.example.knitting_course_platform.entity.Answer;
import com.example.knitting_course_platform.entity.Question;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.ForbiddenException;
import com.example.knitting_course_platform.exception.ResourceNotFoundException;
import com.example.knitting_course_platform.repository.AnswerRepository;
import com.example.knitting_course_platform.repository.QuestionRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnswerService {

    private final AnswerRepository answerRepository;
    private final QuestionRepository questionRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<AnswerDetailResponse> getAnswers(Long questionId) {
        return answerRepository.findAllByQuestion_QuestionIdOrderByCreatedAtAsc(questionId)
            .stream().map(AnswerDetailResponse::from).toList();
    }

    @Transactional
    public AnswerDetailResponse createAnswer(Long userId, Long questionId, AnswerCreateRequest req) {
        User instructor = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalStateException("사용자를 찾을 수 없습니다"));
        if (!"INSTRUCTOR".equals(instructor.getRole())) {
            throw new ForbiddenException("강사만 답변을 작성할 수 있습니다");
        }
        Question question = questionRepository.findById(questionId)
            .orElseThrow(() -> new ResourceNotFoundException("질문을 찾을 수 없습니다"));
        if (!question.getLecture().getUser().getUserId().equals(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        Answer answer = Answer.create(question, instructor, req.content());
        answerRepository.save(answer);
        return AnswerDetailResponse.from(answer);
    }

    @Transactional
    public AnswerDetailResponse updateAnswer(Long userId, Long answerId, AnswerUpdateRequest req) {
        Answer answer = answerRepository.findById(answerId)
            .orElseThrow(() -> new ResourceNotFoundException("답변을 찾을 수 없습니다"));
        if (!answer.getUser().getUserId().equals(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        answer.update(req.content());
        return AnswerDetailResponse.from(answer);
    }

    @Transactional
    public void deleteAnswer(Long userId, Long answerId) {
        Answer answer = answerRepository.findById(answerId)
            .orElseThrow(() -> new ResourceNotFoundException("답변을 찾을 수 없습니다"));
        if (!answer.getUser().getUserId().equals(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        answerRepository.delete(answer);
    }
}
