package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.*;
import com.example.knitting_course_platform.entity.*;
import com.example.knitting_course_platform.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LectureService {

    private final LectureRepository lectureRepository;
    private final LecturePartRepository lecturePartRepository;
    private final VideoRepository videoRepository;
    private final LecturePatternRepository lecturePatternRepository;
    private final PartPatternRepository partPatternRepository;
    private final TagRepository tagRepository;

    // GET /api/lectures
    public List<LectureListResponse> getLectures(String keyword) {
        return lectureRepository.search(keyword)
                .stream()
                .map(LectureListResponse::from)
                .toList();
    }

    // GET /api/lectures/{lectureId}
    public LectureDetailResponse getLectureDetail(Long lectureId) {
        Lecture lecture = lectureRepository.findById(lectureId)
                .orElseThrow(() -> new IllegalArgumentException("강의를 찾을 수 없습니다: " + lectureId));
        return LectureDetailResponse.from(lecture);
    }

    // GET /api/lectures/{lectureId}/parts
    public List<LecturePartResponse> getLectureParts(Long lectureId) {
        return lecturePartRepository.findByLectureLectureIdOrderByOrderNoAsc(lectureId)
                .stream()
                .map(LecturePartResponse::from)
                .toList();
    }

    // GET /api/parts/{partId}/video
    public VideoResponse getPartVideo(Long partId) {
        Video video = videoRepository.findByLecturePartPartId(partId)
                .orElseThrow(() -> new IllegalArgumentException("영상을 찾을 수 없습니다: partId=" + partId));
        return VideoResponse.from(video);
    }

    // GET /api/lectures/{lectureId}/patterns
    public List<LecturePatternResponse> getLecturePatterns(Long lectureId) {
        return lecturePatternRepository.findByLectureLectureIdOrderByRowNumAsc(lectureId)
                .stream()
                .map(LecturePatternResponse::from)
                .toList();
    }

    // GET /api/parts/{partId}/patterns
    public List<PartPatternResponse> getPartPatterns(Long partId) {
        return partPatternRepository.findByLecturePartPartIdOrderByRowNumAsc(partId)
                .stream()
                .map(PartPatternResponse::from)
                .toList();
    }

    // GET /api/tags
    public List<String> getTags() {
        return tagRepository.findAllTagNames();
    }
}
