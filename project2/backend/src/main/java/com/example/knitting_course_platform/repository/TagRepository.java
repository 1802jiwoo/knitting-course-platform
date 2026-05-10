package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface TagRepository extends JpaRepository<Tag, Long> {

    @Query("SELECT t.tagName FROM Tag t ORDER BY t.tagId ASC")
    List<String> findAllTagNames();

    List<Tag> findByTagNameIn(List<String> tagNames);

    Optional<Tag> findByTagName(String tagName);
}
