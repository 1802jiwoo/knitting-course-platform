package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.AdminApplicationResponse;
import com.example.knitting_course_platform.dto.AdminLectureResponse;
import com.example.knitting_course_platform.entity.InstructorApplication;
import com.example.knitting_course_platform.entity.Lecture;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.ResourceNotFoundException;
import com.example.knitting_course_platform.repository.InstructorApplicationRepository;
import com.example.knitting_course_platform.repository.LectureRepository;
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
    private final LectureRepository lectureRepository;
    private final DiscordWebhookService discordWebhookService;
    private final EmailService emailService;

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
        emailService.sendApproved(user.getEmail(), user.getNickname());
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
        emailService.sendRejected(user.getEmail(), user.getNickname());
    }

    // 검토 대기(PENDING) 강의 목록
    @Transactional(readOnly = true)
    public List<AdminLectureResponse> getPendingLectures() {
        return lectureRepository.findAllByStatusOrderByCreatedAtAsc("PENDING")
                .stream()
                .map(AdminLectureResponse::from)
                .toList();
    }

    // 강의 승인
    @Transactional
    public void approveLecture(Long lectureId) {
        Lecture lecture = lectureRepository.findById(lectureId)
                .orElseThrow(() -> new ResourceNotFoundException("강의를 찾을 수 없습니다"));
        if (!"PENDING".equals(lecture.getStatus())) {
            throw new IllegalArgumentException("검토 요청 중인 강의만 승인할 수 있습니다");
        }
        lecture.approve();
        log.info("강의 승인 lectureId={} userId={}", lectureId, lecture.getUser().getUserId());
    }

    // 강의 거절
    @Transactional
    public void rejectLecture(Long lectureId) {
        Lecture lecture = lectureRepository.findById(lectureId)
                .orElseThrow(() -> new ResourceNotFoundException("강의를 찾을 수 없습니다"));
        if (!"PENDING".equals(lecture.getStatus())) {
            throw new IllegalArgumentException("검토 요청 중인 강의만 거절할 수 있습니다");
        }
        lecture.reject();
        log.info("강의 거절 lectureId={} userId={}", lectureId, lecture.getUser().getUserId());
    }
}
