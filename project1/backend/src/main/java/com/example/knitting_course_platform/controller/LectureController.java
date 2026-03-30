package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.service.LectureService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class LectureController {

    private final LectureService lectureService;

    // GET /api/lectures?title=&tag=&instructor=
    @GetMapping("/lectures")
    public List<LectureListResponse> getLectures(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String tag,
            @RequestParam(required = false) String instructor
    ) {
        return lectureService.getLectures(title, tag, instructor);
    }

    // GET /api/lectures/{lectureId}
    @GetMapping("/lectures/{lectureId}")
    public LectureDetailResponse getLectureDetail(@PathVariable Long lectureId) {
        return lectureService.getLectureDetail(lectureId);
    }

    // GET /api/lectures/{lectureId}/parts
    @GetMapping("/lectures/{lectureId}/parts")
    public List<LecturePartResponse> getLectureParts(@PathVariable Long lectureId) {
        return lectureService.getLectureParts(lectureId);
    }

    // GET /api/lectures/{lectureId}/patterns
    @GetMapping("/lectures/{lectureId}/patterns")
    public List<LecturePatternResponse> getLecturePatterns(@PathVariable Long lectureId) {
        return lectureService.getLecturePatterns(lectureId);
    }

    // GET /api/lectures/{lectureId}/questions — QuestionController로 위임
    // (QuestionController 에서 처리)

    // GET /api/parts/{partId}/video
    @GetMapping("/parts/{partId}/video")
    public VideoResponse getPartVideo(@PathVariable Long partId) {
        return lectureService.getPartVideo(partId);
    }

    // GET /api/parts/{partId}/patterns
    @GetMapping("/parts/{partId}/patterns")
    public List<PartPatternResponse> getPartPatterns(@PathVariable Long partId) {
        return lectureService.getPartPatterns(partId);
    }

    // GET /api/tags
    @GetMapping("/tags")
    public List<String> getTags() {
        return lectureService.getTags();
    }
}
