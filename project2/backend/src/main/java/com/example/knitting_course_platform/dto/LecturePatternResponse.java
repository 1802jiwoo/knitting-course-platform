package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.LecturePattern;

/// GET /api/lectures/{lectureId}/patterns 응답 DTO
/// API 명세: rowNumber (DB: row_num)
public record LecturePatternResponse(
    Long patternId,
    Integer rowNumber,
    String patternText
) {
    public static LecturePatternResponse from(LecturePattern p) {
        return new LecturePatternResponse(
            p.getPatternId(),
            p.getRowNum(),
            p.getPatternText()
        );
    }
}
