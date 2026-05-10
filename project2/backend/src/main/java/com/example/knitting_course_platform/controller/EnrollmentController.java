package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.service.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/enrollments")
@RequiredArgsConstructor
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EnrollmentCreateResponse enroll(Authentication authentication,
                                           @RequestBody EnrollmentRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return enrollmentService.enroll(userId, request);
    }

    @DeleteMapping("/{enrollmentId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void cancel(Authentication authentication,
                       @PathVariable Long enrollmentId) {
        Long userId = (Long) authentication.getPrincipal();
        enrollmentService.cancel(userId, enrollmentId);
    }

    @GetMapping("/my")
    public List<EnrollmentSummaryResponse> getMyEnrollments(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return enrollmentService.getMyEnrollments(userId);
    }

    @PostMapping("/{enrollmentId}/complete-part")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void completePart(Authentication authentication,
                             @PathVariable Long enrollmentId,
                             @RequestBody CompletePartRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        enrollmentService.completePart(userId, enrollmentId, request);
    }
}
