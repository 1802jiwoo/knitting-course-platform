package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.AnswerCreateRequest;
import com.example.knitting_course_platform.dto.AnswerDetailResponse;
import com.example.knitting_course_platform.dto.AnswerUpdateRequest;
import com.example.knitting_course_platform.service.AnswerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AnswerController {

    private final AnswerService answerService;

    @GetMapping("/questions/{questionId}/answer")
    public List<AnswerDetailResponse> getAnswers(@PathVariable Long questionId) {
        return answerService.getAnswers(questionId);
    }

    @PostMapping("/questions/{questionId}/answer")
    @ResponseStatus(HttpStatus.CREATED)
    public AnswerDetailResponse createAnswer(Authentication authentication,
                                             @PathVariable Long questionId,
                                             @Valid @RequestBody AnswerCreateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return answerService.createAnswer(userId, questionId, request);
    }

    @PatchMapping("/answers/{answerId}")
    public AnswerDetailResponse updateAnswer(Authentication authentication,
                                             @PathVariable Long answerId,
                                             @Valid @RequestBody AnswerUpdateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return answerService.updateAnswer(userId, answerId, request);
    }

    @DeleteMapping("/answers/{answerId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAnswer(Authentication authentication,
                             @PathVariable Long answerId) {
        Long userId = (Long) authentication.getPrincipal();
        answerService.deleteAnswer(userId, answerId);
    }
}
