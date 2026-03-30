package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.PatternSymbolResponse;
import com.example.knitting_course_platform.repository.PatternSymbolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PatternSymbolService {

    private final PatternSymbolRepository patternSymbolRepository;

    // GET /api/pattern-symbols
    public List<PatternSymbolResponse> getAllSymbols() {
        return patternSymbolRepository.findAll()
                .stream()
                .map(PatternSymbolResponse::from)
                .toList();
    }

    // GET /api/pattern-symbols/{symbol}
    public PatternSymbolResponse getSymbol(String symbol) {
        return patternSymbolRepository.findBySymbol(symbol)
                .map(PatternSymbolResponse::from)
                .orElseThrow(() -> new IllegalArgumentException("기호를 찾을 수 없습니다: " + symbol));
    }
}
