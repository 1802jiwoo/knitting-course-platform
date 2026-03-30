package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.PatternSymbol;

/// GET /api/pattern-symbols, GET /api/pattern-symbols/{symbol} 응답 DTO
public record PatternSymbolResponse(
    Long symbolId,
    String symbol,
    String description
) {
    public static PatternSymbolResponse from(PatternSymbol s) {
        return new PatternSymbolResponse(
            s.getSymbolId(),
            s.getSymbol(),
            s.getDescription()
        );
    }
}
