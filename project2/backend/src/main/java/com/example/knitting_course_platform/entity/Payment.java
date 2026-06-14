package com.example.knitting_course_platform.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment", indexes = {
    @Index(name = "idx_payment_user", columnList = "user_id"),
    @Index(name = "idx_payment_lecture", columnList = "lecture_id")
})
@Getter
@NoArgsConstructor
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_id")
    private Long paymentId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "lecture_id", nullable = false)
    private Long lectureId;

    @Column(name = "order_id", nullable = false, unique = true)
    private String orderId;

    @Column(name = "payment_key", nullable = false)
    private String paymentKey;

    @Column(nullable = false)
    private int amount;

    @Column(nullable = false)
    private String status = "DONE";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public static Payment create(Long userId, Long lectureId, String orderId, String paymentKey, int amount) {
        Payment p = new Payment();
        p.userId = userId;
        p.lectureId = lectureId;
        p.orderId = orderId;
        p.paymentKey = paymentKey;
        p.amount = amount;
        p.status = "DONE";
        return p;
    }
}
