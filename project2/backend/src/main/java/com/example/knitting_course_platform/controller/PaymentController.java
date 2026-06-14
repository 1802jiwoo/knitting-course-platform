package com.example.knitting_course_platform.controller;

import com.example.knitting_course_platform.dto.PaymentConfirmRequest;
import com.example.knitting_course_platform.dto.PaymentConfirmResponse;
import com.example.knitting_course_platform.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/confirm")
    public ResponseEntity<PaymentConfirmResponse> confirm(
            Authentication authentication,
            @Valid @RequestBody PaymentConfirmRequest req
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(paymentService.confirm(userId, req));
    }
}
