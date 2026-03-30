package com.example.knitting_course_platform.repository;

import com.example.knitting_course_platform.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
}