package com.example.knitting_course_platform.dto;

import com.example.knitting_course_platform.entity.Payment;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class PaymentConfirmResponse {
    private final Long paymentId;
    private final String orderId;
    private final String paymentKey;
    private final int amount;
    private final String status;
    private final LocalDateTime createdAt;

    private PaymentConfirmResponse(Payment p) {
        this.paymentId = p.getPaymentId();
        this.orderId = p.getOrderId();
        this.paymentKey = p.getPaymentKey();
        this.amount = p.getAmount();
        this.status = p.getStatus();
        this.createdAt = p.getCreatedAt();
    }

    public static PaymentConfirmResponse from(Payment p) {
        return new PaymentConfirmResponse(p);
    }
}
