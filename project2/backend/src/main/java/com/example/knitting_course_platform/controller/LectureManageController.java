package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.service.LectureManageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/lectures")
@RequiredArgsConstructor
public class LectureManageController {

    private final LectureManageService lectureManageService;

    // 강의 등록
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Long> createLecture(
            Authentication authentication,
            @RequestPart("data") @Valid LectureCreateRequest request,
            @RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail) {
        Long userId = (Long) authentication.getPrincipal();
        Long lectureId = lectureManageService.createLecture(userId, request, thumbnail);
        return Map.of("lectureId", lectureId);
    }

    // 강의 수정
    @PatchMapping(value = "/{lectureId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateLecture(
            Authentication authentication,
            @PathVariable Long lectureId,
            @RequestPart("data") LectureUpdateRequest request,
            @RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.updateLecture(userId, lectureId, request, thumbnail);
    }

    // 강의 삭제
    @DeleteMapping("/{lectureId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteLecture(
            Authentication authentication,
            @PathVariable Long lectureId) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.deleteLecture(userId, lectureId);
    }

    // 강사 강의 목록
    @GetMapping("/my")
    public List<MyLectureListResponse> getMyLectures(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return lectureManageService.getMyLectures(userId);
    }

    // 검토 요청
    @PostMapping("/{lectureId}/submit")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void submitLecture(
            Authentication authentication,
            @PathVariable Long lectureId) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.submitLecture(userId, lectureId);
    }

    // 파트 추가
    @PostMapping("/{lectureId}/parts")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Long> addPart(
            Authentication authentication,
            @PathVariable Long lectureId,
            @Valid @RequestBody PartCreateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        Long partId = lectureManageService.addPart(userId, lectureId, request);
        return Map.of("partId", partId);
    }

    // 파트 순서 변경
    @PatchMapping("/{lectureId}/parts/reorder")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reorderParts(
            Authentication authentication,
            @PathVariable Long lectureId,
            @RequestBody PartReorderRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.reorderParts(userId, lectureId, request);
    }

    // 강의 단위 도안 삭제
    @DeleteMapping("/{lectureId}/patterns/{patternId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteLecturePattern(
            Authentication authentication,
            @PathVariable Long lectureId,
            @PathVariable Long patternId) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.deleteLecturePattern(userId, lectureId, patternId);
    }

    // 강의 단위 도안 수정
    @PatchMapping("/{lectureId}/patterns/{patternId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateLecturePattern(
            Authentication authentication,
            @PathVariable Long lectureId,
            @PathVariable Long patternId,
            @Valid @RequestBody LecturePatternUpdateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.updateLecturePattern(userId, lectureId, patternId, request);
    }

    // 강의 단위 도안 등록
    @PostMapping("/{lectureId}/patterns")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Long> addLecturePattern(
            Authentication authentication,
            @PathVariable Long lectureId,
            @Valid @RequestBody LecturePatternCreateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        Long patternId = lectureManageService.addLecturePattern(userId, lectureId, request);
        return Map.of("patternId", patternId);
    }
}
