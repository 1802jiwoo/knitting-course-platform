package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.Video;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface VideoRepository extends JpaRepository<Video, Long> {
    Optional<Video> findByLecturePartPartId(Long partId);
}
