package com.example.knitting_course_platform.service;

import com.example.knitting_course_platform.dto.PaymentConfirmRequest;
import com.example.knitting_course_platform.dto.PaymentConfirmResponse;
import com.example.knitting_course_platform.entity.Enrollment;
import com.example.knitting_course_platform.entity.Lecture;
import com.example.knitting_course_platform.entity.Payment;
import com.example.knitting_course_platform.entity.User;
import com.example.knitting_course_platform.exception.ResourceNotFoundException;
import com.example.knitting_course_platform.repository.EnrollmentRepository;
import com.example.knitting_course_platform.repository.LectureRepository;
import com.example.knitting_course_platform.repository.PaymentRepository;
import com.example.knitting_course_platform.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final LectureRepository lectureRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${toss.secret-key}")
    private String secretKey;

    private static final String TOSS_CONFIRM_URL = "https://api.tosspayments.com/v1/payments/confirm";

    @Transactional
    public PaymentConfirmResponse confirm(Long userId, PaymentConfirmRequest req) {
        // 1. Toss 승인 API 호출
        callTossConfirm(req.getPaymentKey(), req.getOrderId(), req.getAmount());

        // 2. 결제 내역 저장
        Payment payment = Payment.create(userId, req.getLectureId(), req.getOrderId(), req.getPaymentKey(), req.getAmount());
        paymentRepository.save(payment);

        // 3. 수강 등록
        Lecture lecture = lectureRepository.findById(req.getLectureId())
                .orElseThrow(() -> new ResourceNotFoundException("강의를 찾을 수 없습니다"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("사용자를 찾을 수 없습니다"));
        if (!enrollmentRepository.existsByUser_UserIdAndLecture_LectureId(userId, req.getLectureId())) {
            enrollmentRepository.save(Enrollment.create(user, lecture));
        }

        log.info("결제 완료 userId={} lectureId={} amount={} orderId={}", userId, req.getLectureId(), req.getAmount(), req.getOrderId());
        return PaymentConfirmResponse.from(payment);
    }

    private void callTossConfirm(String paymentKey, String orderId, int amount) {
        // 테스트 bypass: paymentKey가 "test_bypass_"로 시작하면 Toss API 호출 생략
        if (paymentKey.startsWith("test_bypass_")) {
            log.info("테스트 결제 bypass orderId={} amount={}", orderId, amount);
            return;
        }

        String encoded = Base64.getEncoder().encodeToString((secretKey + ":").getBytes());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Basic " + encoded);

        Map<String, Object> body = Map.of(
                "paymentKey", paymentKey,
                "orderId", orderId,
                "amount", amount
        );

        ResponseEntity<String> response = restTemplate.postForEntity(
                TOSS_CONFIRM_URL,
                new HttpEntity<>(body, headers),
                String.class
        );

        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new IllegalStateException("Toss 결제 승인 실패: " + response.getBody());
        }
    }
}
