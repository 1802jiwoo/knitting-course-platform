package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.entity.*;
import com.example.knitting_course_platform.exception.ForbiddenException;
import com.example.knitting_course_platform.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class LectureManageService {

    private final LectureRepository lectureRepository;
    private final LecturePartRepository lecturePartRepository;
    private final VideoRepository videoRepository;
    private final TagRepository tagRepository;
    private final LectureTagRepository lectureTagRepository;
    private final UserRepository userRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final LecturePatternRepository lecturePatternRepository;
    private final PartPatternRepository partPatternRepository;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${server.base-url}")
    private String baseUrl;

    // 강의 등록
    public Long createLecture(Long userId, LectureCreateRequest req, MultipartFile thumbnail) {
        User user = getInstructor(userId);
        String thumbnailUrl = saveThumbnail(thumbnail);
        Lecture lecture = Lecture.create(user, req.title(), req.description(), req.lectureType(), thumbnailUrl);
        lectureRepository.save(lecture);
        saveTags(lecture, req.tagNames());
        return lecture.getLectureId();
    }

    // 강의 수정
    public void updateLecture(Long userId, Long lectureId, LectureUpdateRequest req, MultipartFile thumbnail) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        if (!lecture.isEditable()) {
            throw new IllegalArgumentException("검토 요청 중인 강의는 수정할 수 없습니다");
        }
        String thumbnailUrl = (thumbnail != null && !thumbnail.isEmpty()) ? saveThumbnail(thumbnail) : null;
        lecture.update(req.title(), req.description(), req.lectureType(), thumbnailUrl);
        if (req.tagNames() != null) {
            lectureTagRepository.deleteByLectureLectureId(lectureId);
            saveTags(lecture, req.tagNames());
        }
    }

    // 강의 삭제
    public void deleteLecture(Long userId, Long lectureId) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        if (!lecture.isDeletable()) {
            throw new IllegalArgumentException("현재 상태에서는 강의를 삭제할 수 없습니다");
        }
        lectureRepository.delete(lecture);
    }

    // 강사 강의 목록
    @Transactional(readOnly = true)
    public List<MyLectureListResponse> getMyLectures(Long userId) {
        return lectureRepository.findByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(l -> MyLectureListResponse.from(l, enrollmentRepository.countByLectureId(l.getLectureId())))
                .toList();
    }

    // 강의 검토 요청
    public void submitLecture(Long userId, Long lectureId) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        String status = lecture.getStatus();
        if (!"DRAFT".equals(status) && !"REJECTED".equals(status)) {
            throw new IllegalArgumentException("DRAFT 또는 REJECTED 상태의 강의만 검토 요청할 수 있습니다");
        }
        if (!"PATTERN".equals(lecture.getLectureType()) && lecture.getParts().isEmpty()) {
            throw new IllegalArgumentException("강의 파트를 1개 이상 등록해 주세요");
        }
        if ("PATTERN".equals(lecture.getLectureType()) && lecture.getLecturePatterns().isEmpty()) {
            throw new IllegalArgumentException("강의 단위 도안을 1개 이상 등록해 주세요");
        }
        lecture.submit();
    }

    // 파트 추가
    public Long addPart(Long userId, Long lectureId, PartCreateRequest req) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        if ("HIDDEN".equals(lecture.getStatus())) {
            throw new IllegalArgumentException("비공개 처리된 강의에는 파트를 추가할 수 없습니다");
        }
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        int nextOrder = lecturePartRepository.findMaxOrderNoByLectureId(lectureId) + 1;
        LecturePart part = LecturePart.create(lecture, req.title(), nextOrder);
        lecturePartRepository.save(part);
        if (!"PATTERN".equals(lecture.getLectureType()) && req.youtubeUrl() != null) {
            videoRepository.save(Video.create(part, req.youtubeUrl(), req.duration()));
        }
        return part.getPartId();
    }

    // 파트 수정
    public void updatePart(Long userId, Long partId, PartUpdateRequest req) {
        LecturePart part = getPartOwnedBy(partId, userId);
        Lecture lecture = part.getLecture();
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        part.update(req.title());
        if (req.youtubeUrl() != null) {
            Video video = part.getVideo();
            if (video != null) {
                video.update(req.youtubeUrl(), req.duration());
            } else {
                videoRepository.save(Video.create(part, req.youtubeUrl(), req.duration()));
            }
        }
    }

    // 파트 삭제
    public void deletePart(Long userId, Long partId) {
        LecturePart part = getPartOwnedBy(partId, userId);
        Lecture lecture = part.getLecture();
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        lecturePartRepository.delete(part);
        List<LecturePart> remaining = lecturePartRepository.findByLectureLectureIdOrderByOrderNoAsc(lecture.getLectureId());
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).updateOrderNo(i + 1);
        }
    }

    // 파트 순서 변경
    public void reorderParts(Long userId, Long lectureId, PartReorderRequest req) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        List<LecturePart> parts = lecturePartRepository.findByLectureLectureIdOrderByOrderNoAsc(lectureId);
        Set<Long> validIds = parts.stream().map(LecturePart::getPartId).collect(Collectors.toSet());
        if (!validIds.containsAll(req.partIds()) || req.partIds().size() != parts.size()) {
            throw new IllegalArgumentException("올바르지 않은 파트 목록입니다");
        }
        Map<Long, LecturePart> partMap = parts.stream().collect(Collectors.toMap(LecturePart::getPartId, p -> p));
        for (int i = 0; i < req.partIds().size(); i++) {
            partMap.get(req.partIds().get(i)).updateOrderNo(i + 1);
        }
    }

    // 파트 단위 도안 삭제
    public void deletePartPattern(Long userId, Long partId, Long patternId) {
        LecturePart part = getPartOwnedBy(partId, userId);
        PartPattern pattern = partPatternRepository.findById(patternId)
                .orElseThrow(() -> new IllegalArgumentException("도안을 찾을 수 없습니다"));
        if (!pattern.getLecturePart().getPartId().equals(partId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        Lecture lecture = part.getLecture();
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        partPatternRepository.delete(pattern);
        List<PartPattern> remaining = partPatternRepository.findByLecturePartPartIdOrderByRowNumAsc(partId);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).updateRowNum(i + 1);
        }
    }

    // 파트 단위 도안 수정
    public void updatePartPattern(Long userId, Long partId, Long patternId, PartPatternUpdateRequest req) {
        LecturePart part = getPartOwnedBy(partId, userId);
        PartPattern pattern = partPatternRepository.findById(patternId)
                .orElseThrow(() -> new IllegalArgumentException("도안을 찾을 수 없습니다"));
        if (!pattern.getLecturePart().getPartId().equals(partId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        Integer newStart = req.startTime() != null ? req.startTime() : pattern.getStartTime();
        Integer newEnd = req.endTime() != null ? req.endTime() : pattern.getEndTime();
        if (newEnd <= newStart) {
            throw new IllegalArgumentException("endTime은 startTime보다 커야 합니다");
        }
        Lecture lecture = part.getLecture();
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        pattern.update(req.startTime(), req.endTime(), req.patternText());
    }

    // 파트 단위 도안 등록
    public Long addPartPattern(Long userId, Long partId, PartPatternCreateRequest req) {
        LecturePart part = getPartOwnedBy(partId, userId);
        if (req.endTime() <= req.startTime()) {
            throw new IllegalArgumentException("endTime은 startTime보다 커야 합니다");
        }
        Lecture lecture = part.getLecture();
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        int nextRowNum = partPatternRepository.findMaxRowNumByPartId(partId) + 1;
        PartPattern pattern = PartPattern.create(part, req.startTime(), req.endTime(), nextRowNum, req.patternText());
        partPatternRepository.save(pattern);
        return pattern.getPatternId();
    }

    // 강의 단위 도안 삭제
    public void deleteLecturePattern(Long userId, Long lectureId, Long patternId) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        LecturePattern pattern = lecturePatternRepository.findById(patternId)
                .orElseThrow(() -> new IllegalArgumentException("도안을 찾을 수 없습니다"));
        if (!pattern.getLecture().getLectureId().equals(lectureId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        lecturePatternRepository.delete(pattern);
        List<LecturePattern> remaining = lecturePatternRepository.findByLectureLectureIdOrderByRowNumAsc(lectureId);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).updateRowNum(i + 1);
        }
    }

    // 강의 단위 도안 수정
    public void updateLecturePattern(Long userId, Long lectureId, Long patternId, LecturePatternUpdateRequest req) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        LecturePattern pattern = lecturePatternRepository.findById(patternId)
                .orElseThrow(() -> new IllegalArgumentException("도안을 찾을 수 없습니다"));
        if (!pattern.getLecture().getLectureId().equals(lectureId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        pattern.update(req.patternText());
    }

    // 강의 단위 도안 등록
    public Long addLecturePattern(Long userId, Long lectureId, LecturePatternCreateRequest req) {
        Lecture lecture = getLectureOwnedBy(lectureId, userId);
        if (!"PATTERN".equals(lecture.getLectureType())) {
            throw new IllegalArgumentException("PATTERN 유형 강의에만 도안을 등록할 수 있습니다");
        }
        if ("HIDDEN".equals(lecture.getStatus())) {
            throw new IllegalArgumentException("비공개 처리된 강의에는 도안을 추가할 수 없습니다");
        }
        if ("APPROVED".equals(lecture.getStatus())) {
            lecture.revertToDraft();
        }
        int nextRowNum = lecturePatternRepository.findMaxRowNumByLectureId(lectureId) + 1;
        LecturePattern pattern = LecturePattern.create(lecture, nextRowNum, req.patternText());
        lecturePatternRepository.save(pattern);
        return pattern.getPatternId();
    }

    // ── helpers ──────────────────────────────────────────────────────────

    private User getInstructor(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다"));
        if (!"INSTRUCTOR".equals(user.getRole())) {
            throw new ForbiddenException("강사 권한이 필요합니다");
        }
        return user;
    }

    private Lecture getLectureOwnedBy(Long lectureId, Long userId) {
        Lecture lecture = lectureRepository.findById(lectureId)
                .orElseThrow(() -> new IllegalArgumentException("강의를 찾을 수 없습니다"));
        if (!lecture.isOwnedBy(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        return lecture;
    }

    private LecturePart getPartOwnedBy(Long partId, Long userId) {
        LecturePart part = lecturePartRepository.findById(partId)
                .orElseThrow(() -> new IllegalArgumentException("파트를 찾을 수 없습니다"));
        if (!part.getLecture().isOwnedBy(userId)) {
            throw new ForbiddenException("접근 권한이 없습니다");
        }
        return part;
    }

    private void saveTags(Lecture lecture, List<String> tagNames) {
        if (tagNames == null || tagNames.isEmpty()) return;
        for (String tagName : tagNames) {
            Tag tag = tagRepository.findByTagName(tagName)
                    .orElseGet(() -> tagRepository.save(Tag.create(tagName)));
            lectureTagRepository.save(LectureTag.create(lecture, tag));
        }
    }

    private String saveThumbnail(MultipartFile file) {
        if (file == null || file.isEmpty()) return null;
        try {
            String original = file.getOriginalFilename();
            String ext = (original != null && original.contains("."))
                    ? original.substring(original.lastIndexOf('.')) : ".jpg";
            String fileName = UUID.randomUUID() + ext;
            Path dir = Paths.get(uploadDir, "thumbnails");
            Files.createDirectories(dir);
            Files.write(dir.resolve(fileName), file.getBytes());
            return baseUrl + "/uploads/thumbnails/" + fileName;
        } catch (IOException e) {
            throw new IllegalArgumentException("썸네일 저장 중 오류가 발생했습니다");
        }
    }
}
