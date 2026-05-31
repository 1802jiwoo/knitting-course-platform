package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.AdminApplicationResponse;
import com.example.knitting_course_platform.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    // PENDING 강사 신청 목록
    @GetMapping("/instructor-applications")
    public List<AdminApplicationResponse> getPendingApplications() {
        return adminService.getPendingApplications();
    }

    // 강사 신청 승인
    @PostMapping("/instructor-applications/{applicationId}/approve")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void approve(@PathVariable Long applicationId) {
        adminService.approve(applicationId);
    }

    // 강사 신청 거절
    @PostMapping("/instructor-applications/{applicationId}/reject")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reject(@PathVariable Long applicationId) {
        adminService.reject(applicationId);
    }
}
