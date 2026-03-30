package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.PartPattern;

/// GET /api/parts/{partId}/patterns 응답 DTO
/// API 명세: rowNumber / startTime / endTime (DB: row_num / start_time / end_time)
public record PartPatternResponse(
    Long patternId,
    Integer startTime,
    Integer endTime,
    Integer rowNumber,
    String patternText
) {
    public static PartPatternResponse from(PartPattern p) {
        return new PartPatternResponse(
            p.getPatternId(),
            p.getStartTime(),
            p.getEndTime(),
            p.getRowNum(),
            p.getPatternText()
        );
    }
}
