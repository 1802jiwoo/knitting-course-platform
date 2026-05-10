package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.PatternSymbol;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface PatternSymbolRepository extends JpaRepository<PatternSymbol, Long> {
    Optional<PatternSymbol> findBySymbol(String symbol);
}
