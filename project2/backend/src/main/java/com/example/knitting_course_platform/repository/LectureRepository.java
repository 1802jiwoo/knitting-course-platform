package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Lecture;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface LectureRepository extends JpaRepository<Lecture, Long> {

    // 공개 목록: APPROVED 강의만
    @Query("""
        SELECT DISTINCT l FROM Lecture l
        LEFT JOIN l.user u
        LEFT JOIN l.lectureTags lt
        LEFT JOIN lt.tag t
        WHERE l.status = 'APPROVED'
          AND (:keyword IS NULL
               OR l.title LIKE CONCAT('%', :keyword, '%')
               OR u.nickname LIKE CONCAT('%', :keyword, '%')
               OR t.tagName LIKE CONCAT('%', :keyword, '%'))
        ORDER BY l.lectureId ASC
    """)
    List<Lecture> searchApproved(@Param("keyword") String keyword);

    // 강사 본인 강의 전체
    List<Lecture> findByUserUserIdOrderByCreatedAtDesc(Long userId);
}
