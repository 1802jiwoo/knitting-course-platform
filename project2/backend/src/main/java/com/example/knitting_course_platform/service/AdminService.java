package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.AdminApplicationResponse;
import com.example.knitting_course_platform.entity.InstructorApplication;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.ResourceNotFoundException;
import com.example.knitting_course_platform.repository.InstructorApplicationRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminService {

    private final InstructorApplicationRepository applicationRepository;
    private final UserRepository userRepository;
    private final DiscordWebhookService discordWebhookService;

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
        log.info("강사 승인 applicationId={} userId={}", applicationId, application.getUserId());
        discordWebhookService.sendApproved(applicationId, user.getUserId(), user.getNickname());
    }

    @Transactional
    public void reject(Long applicationId) {
        InstructorApplication application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new ResourceNotFoundException("강사 신청을 찾을 수 없습니다"));
        if (!"PENDING".equals(application.getStatus())) {
            throw new IllegalArgumentException("처리 중인 신청만 거절할 수 있습니다");
        }
        User user = userRepository.findById(application.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("사용자를 찾을 수 없습니다"));
        application.reject();
        log.info("강사 거절 applicationId={} userId={}", applicationId, application.getUserId());
        discordWebhookService.sendRejected(applicationId, user.getUserId(), user.getNickname());
    }
}
