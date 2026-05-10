package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.entity.*;
import com.example.knitting_course_platform.exception.*;
import com.example.knitting_course_platform.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final EnrollmentPartRepository enrollmentPartRepository;
    private final LectureRepository lectureRepository;
    private final LecturePartRepository lecturePartRepository;
    private final UserRepository userRepository;

    @Transactional
    public EnrollmentCreateResponse enroll(Long userId, EnrollmentRequest req) {
        Lecture lecture = lectureRepository.findById(req.lectureId())
            .orElseThrow(() -> new ResourceNotFoundException("강의를 찾을 수 없습니다"));
        if (!"APPROVED".equals(lecture.getStatus())) {
            throw new IllegalArgumentException("수강 신청할 수 없는 강의입니다");
        }
        if (enrollmentRepository.existsByUser_UserIdAndLecture_LectureId(userId, req.lectureId())) {
            throw new DuplicateEnrollmentException("이미 수강 중인 강의입니다");
        }
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalStateException("사용자를 찾을 수 없습니다"));
        Enrollment enrollment = Enrollment.create(user, lecture);
        enrollmentRepository.save(enrollment);
        return new EnrollmentCreateResponse(enrollment.getEnrollmentId(), lecture.getLectureId(), enrollment.getCreatedAt());
    }

    @Transactional
    public void cancel(Long userId, Long enrollmentId) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new ResourceNotFoundException("수강 중인 강의가 아닙니다"));
        if (!enrollment.getUser().getUserId().equals(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        enrollmentRepository.delete(enrollment);
    }

    @Transactional(readOnly = true)
    public List<EnrollmentSummaryResponse> getMyEnrollments(Long userId) {
        List<Enrollment> enrollments = enrollmentRepository.findByUser_UserIdOrderByCreatedAtDesc(userId);
        return enrollments.stream().map(e -> {
            Lecture lecture = e.getLecture();
            long totalParts = lecturePartRepository.countByLectureId(lecture.getLectureId());
            List<Long> completedPartIds = enrollmentPartRepository.findPartIdsByEnrollmentId(e.getEnrollmentId());
            double progress = totalParts == 0 ? 0.0 : completedPartIds.size() * 100.0 / totalParts;
            List<String> tags = lecture.getLectureTags().stream()
                .map(lt -> lt.getTag().getTagName())
                .toList();
            return new EnrollmentSummaryResponse(
                e.getEnrollmentId(), lecture.getLectureId(), lecture.getTitle(),
                lecture.getUser().getNickname(), lecture.getLectureType(),
                lecture.getThumbnailUrl(), tags, completedPartIds,
                (int) totalParts, progress, e.getCreatedAt()
            );
        }).toList();
    }

    @Transactional
    public void completePart(Long userId, Long enrollmentId, CompletePartRequest req) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new ResourceNotFoundException("수강 정보를 찾을 수 없습니다"));
        if (!enrollment.getUser().getUserId().equals(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        if (enrollmentPartRepository.existsByEnrollment_EnrollmentIdAndPartId(enrollmentId, req.partId())) {
            return;
        }
        EnrollmentPart part = EnrollmentPart.create(enrollment, req.partId());
        enrollmentPartRepository.save(part);
    }
}
