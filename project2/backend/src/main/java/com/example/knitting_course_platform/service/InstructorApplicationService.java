package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.InstructorApplicationRequest;
import com.example.knitting_course_platform.dto.InstructorApplicationResponse;
import com.example.knitting_course_platform.entity.InstructorApplication;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.DuplicateApplicationException;
import com.example.knitting_course_platform.repository.InstructorApplicationRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class InstructorApplicationService {

    private final InstructorApplicationRepository applicationRepository;
    private final UserRepository userRepository;

    @Transactional
    public InstructorApplicationResponse apply(Long userId, InstructorApplicationRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("사용자를 찾을 수 없습니다"));

        if ("INSTRUCTOR".equals(user.getRole())) {
            throw new DuplicateApplicationException("이미 강사 역할을 보유하고 있습니다");
        }

        if (applicationRepository.existsByUserIdAndStatus(userId, "PENDING")) {
            throw new DuplicateApplicationException("이미 강사 신청이 처리 중입니다");
        }

        InstructorApplication application = InstructorApplication.create(
                userId, req.getBio(), req.getTeachingPlan()
        );
        applicationRepository.save(application);

        return new InstructorApplicationResponse(application);
    }

    @Transactional(readOnly = true)
    public Optional<InstructorApplicationResponse> getMyApplication(Long userId) {
        return applicationRepository.findByUserIdAndStatus(userId, "PENDING")
                .map(InstructorApplicationResponse::new);
    }

    @Transactional
    public void cancel(Long userId) {
        InstructorApplication application = applicationRepository
                .findByUserIdAndStatus(userId, "PENDING")
                .orElseThrow(() -> new IllegalArgumentException("이미 처리된 신청입니다"));

        applicationRepository.delete(application);
    }
}
