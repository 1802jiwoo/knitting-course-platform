package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.User;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class ProfileResponse {

    private final Long userId;
    private final String email;
    private final String nickname;
    private final String role;
    private final String bio;
    private final LocalDateTime createdAt;

    public ProfileResponse(User user) {
        this.userId = user.getUserId();
        this.email = user.getEmail();
        this.nickname = user.getNickname();
        this.role = user.getRole();
        this.bio = user.getBio();
        this.createdAt = user.getCreatedAt();
    }
}
