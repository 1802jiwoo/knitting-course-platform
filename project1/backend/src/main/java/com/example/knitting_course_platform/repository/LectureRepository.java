package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Lecture;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface LectureRepository extends JpaRepository<Lecture, Long> {

    // title / instructor / tag 검색 — 세 조건 모두 선택적
    @Query("""
        SELECT DISTINCT l FROM Lecture l
        LEFT JOIN l.user u
        LEFT JOIN l.lectureTags lt
        LEFT JOIN lt.tag t
        WHERE :keyword IS NULL
           OR l.title LIKE CONCAT('%', :keyword, '%')
           OR u.nickname LIKE CONCAT('%', :keyword, '%')
           OR t.tagName LIKE CONCAT('%', :keyword, '%')
        ORDER BY l.lectureId ASC
    """)
    List<Lecture> search(
        @Param("keyword") String keyword
    );
}
