package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_token")
@Getter
@NoArgsConstructor
public class RefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "token_id")
    private Long tokenId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(nullable = false, unique = true, length = 512)
    private String token;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    public static RefreshToken create(Long userId, String token, LocalDateTime expiresAt) {
        RefreshToken rt = new RefreshToken();
        rt.userId = userId;
        rt.token = token;
        rt.expiresAt = expiresAt;
        return rt;
    }
}
