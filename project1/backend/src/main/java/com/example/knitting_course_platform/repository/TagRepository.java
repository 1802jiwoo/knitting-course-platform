package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface TagRepository extends JpaRepository<Tag, Long> {

    // API 응답: List<String>
    @Query("SELECT t.tagName FROM Tag t ORDER BY t.tagId ASC")
    List<String> findAllTagNames();
}
