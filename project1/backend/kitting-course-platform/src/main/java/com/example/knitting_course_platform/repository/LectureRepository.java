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
        WHERE (:title IS NULL OR l.title LIKE CONCAT('%', :title, '%'))
          AND (:instructor IS NULL OR u.nickname LIKE CONCAT('%', :instructor, '%'))
          AND (:tag IS NULL OR t.tagName = :tag)
        ORDER BY l.lectureId ASC
    """)
    List<Lecture> search(
        @Param("title") String title,
        @Param("instructor") String instructor,
        @Param("tag") String tag
    );
}
