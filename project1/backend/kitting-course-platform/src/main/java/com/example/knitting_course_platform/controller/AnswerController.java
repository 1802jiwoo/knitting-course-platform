package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.AnswerDetailResponse;
import com.example.knitting_course_platform.service.AnswerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AnswerController {

    private final AnswerService answerService;  // 이게 있는지 확인

    @GetMapping("/questions/{questionId}/answer")
    public ResponseEntity<AnswerDetailResponse> getAnswer(@PathVariable Long questionId) {
        return ResponseEntity.ok(answerService.getAnswer(questionId));
    }
}