package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.service.QuestionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    // GET /api/lectures/{lectureId}/questions
    @GetMapping("/lectures/{lectureId}/questions")
    public List<QuestionListResponse> getQuestions(@PathVariable Long lectureId) {
        return questionService.getQuestions(lectureId);
    }

    // GET /api/questions/{questionId}
    @GetMapping("/questions/{questionId}")
    public QuestionDetailResponse getQuestionDetail(@PathVariable Long questionId) {
        return questionService.getQuestionDetail(questionId);
    }

    // POST /api/questions
    @PostMapping(value = "/questions", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public void createQuestion(
            @RequestPart("request") @Valid QuestionCreateRequest request,
            @RequestPart(value = "image", required = false) MultipartFile image) {  // List -> 단일로 변경
        questionService.createQuestion(request, image);
    }
}
