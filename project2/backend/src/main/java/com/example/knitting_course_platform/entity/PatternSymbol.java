package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "PATTERN_SYMBOL")
@Getter
@NoArgsConstructor
public class PatternSymbol {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "symbol_id")
    private Long symbolId;

    @Column(nullable = false, unique = true)
    private String symbol;

    @Column(nullable = false)
    private String description;
}
