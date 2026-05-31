package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.AdminApplicationResponse;
import com.example.knitting_course_platform.entity.InstructorApplication;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.ResourceNotFoundException;
import com.example.knitting_course_platform.repository.InstructorApplicationRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final InstructorApplicationRepository applicationRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<AdminApplicationResponse> getPendingApplications() {
        return applicationRepository.findAllByStatusOrderByCreatedAtAsc("PENDING")
                .stream()
                .map(app -> {
                    User user = userRepository.findById(app.getUserId())
                            .orElseThrow(() -> new ResourceNotFoundException("사용자를 찾을 수 없습니다"));
                    return AdminApplicationResponse.from(app, user);
                })
                .toList();
    }

    @Transactional
    public void approve(Long applicationId) {
        InstructorApplication application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new ResourceNotFoundException("강사 신청을 찾을 수 없습니다"));
        if (!"PENDING".equals(application.getStatus())) {
            throw new IllegalArgumentException("처리 중인 신청만 승인할 수 있습니다");
        }
        User user = userRepository.findById(application.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("사용자를 찾을 수 없습니다"));
        application.approve();
        user.promoteToInstructor();
    }

    @Transactional
    public void reject(Long applicationId) {
        InstructorApplication application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new ResourceNotFoundException("강사 신청을 찾을 수 없습니다"));
        if (!"PENDING".equals(application.getStatus())) {
            throw new IllegalArgumentException("처리 중인 신청만 거절할 수 있습니다");
        }
        application.reject();
    }
}
