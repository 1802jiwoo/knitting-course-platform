package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.PartPatternCreateRequest;
import com.example.knitting_course_platform.dto.PartPatternUpdateRequest;
import com.example.knitting_course_platform.dto.PartUpdateRequest;
import com.example.knitting_course_platform.service.LectureManageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/parts")
@RequiredArgsConstructor
public class PartController {

    private final LectureManageService lectureManageService;

    // 파트 단위 도안 등록
    @PostMapping("/{partId}/patterns")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Long> addPartPattern(
            Authentication authentication,
            @PathVariable Long partId,
            @Valid @RequestBody PartPatternCreateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        Long patternId = lectureManageService.addPartPattern(userId, partId, request);
        return Map.of("patternId", patternId);
    }

    // 파트 단위 도안 삭제
    @DeleteMapping("/{partId}/patterns/{patternId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePartPattern(
            Authentication authentication,
            @PathVariable Long partId,
            @PathVariable Long patternId) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.deletePartPattern(userId, partId, patternId);
    }

    // 파트 단위 도안 수정
    @PatchMapping("/{partId}/patterns/{patternId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updatePartPattern(
            Authentication authentication,
            @PathVariable Long partId,
            @PathVariable Long patternId,
            @Valid @RequestBody PartPatternUpdateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.updatePartPattern(userId, partId, patternId, request);
    }

    // 파트 수정
    @PatchMapping("/{partId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updatePart(
            Authentication authentication,
            @PathVariable Long partId,
            @RequestBody PartUpdateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.updatePart(userId, partId, request);
    }

    // 파트 삭제
    @DeleteMapping("/{partId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePart(
            Authentication authentication,
            @PathVariable Long partId) {
        Long userId = (Long) authentication.getPrincipal();
        lectureManageService.deletePart(userId, partId);
    }
}
