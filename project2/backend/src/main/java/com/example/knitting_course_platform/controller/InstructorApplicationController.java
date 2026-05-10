package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.InstructorApplicationRequest;
import com.example.knitting_course_platform.dto.InstructorApplicationResponse;
import com.example.knitting_course_platform.service.InstructorApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/instructor-applications")
@RequiredArgsConstructor
public class InstructorApplicationController {

    private final InstructorApplicationService applicationService;

    @GetMapping("/me")
    public ResponseEntity<InstructorApplicationResponse> getMyApplication(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return applicationService.getMyApplication(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public InstructorApplicationResponse apply(
            Authentication authentication,
            @Valid @RequestBody InstructorApplicationRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return applicationService.apply(userId, request);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void cancel(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        applicationService.cancel(userId);
    }
}
