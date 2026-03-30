package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.PatternSymbolResponse;
import com.example.knitting_course_platform.service.PatternSymbolService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/pattern-symbols")
@RequiredArgsConstructor
public class PatternSymbolController {

    private final PatternSymbolService patternSymbolService;

    // GET /api/pattern-symbols
    @GetMapping
    public List<PatternSymbolResponse> getAllSymbols() {
        return patternSymbolService.getAllSymbols();
    }

    // GET /api/pattern-symbols/{symbol}
    @GetMapping("/{symbol}")
    public PatternSymbolResponse getSymbol(@PathVariable String symbol) {
        return patternSymbolService.getSymbol(symbol);
    }
}
