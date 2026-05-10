package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "`USER`")  // USER 는 MySQL 예약어 — 백틱으로 감싸야 함
@Getter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String nickname;

    @Column(nullable = false)
    private String role;

    @Column(name = "is_suspended", nullable = false)
    private boolean isSuspended = false;

    @Column(name = "is_deleted", nullable = false)
    private boolean isDeleted = false;

    @Column(length = 500)
    private String bio;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public static User create(String email, String encodedPassword, String nickname) {
        User user = new User();
        user.email = email;
        user.password = encodedPassword;
        user.nickname = nickname;
        user.role = "STUDENT";
        user.isSuspended = false;
        return user;
    }

    public void updateProfile(String nickname, String bio) {
        if (nickname != null) this.nickname = nickname;
        if (bio != null) this.bio = bio;
    }

    public void changePassword(String encodedPassword) {
        this.password = encodedPassword;
    }

    public void delete() {
        this.isDeleted = true;
    }
}
