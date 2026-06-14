package com.example.knitting_course_platform.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendApproved(String toEmail, String nickname) {
        send(toEmail,
                "[LoopLearn] 강사 신청이 승인되었습니다",
                nickname + "님, 안녕하세요!\n\n강사 신청이 승인되었습니다. 이제 강의를 등록하실 수 있습니다.\n\nLoopLearn 팀 드림");
    }

    public void sendRejected(String toEmail, String nickname) {
        send(toEmail,
                "[LoopLearn] 강사 신청 결과 안내",
                nickname + "님, 안녕하세요.\n\n아쉽게도 이번 강사 신청은 승인되지 않았습니다.\n추후 다시 신청해 주세요.\n\nLoopLearn 팀 드림");
    }

    private void send(String to, String subject, String text) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("1802jiwoo@naver.com");
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            mailSender.send(message);
            log.info("이메일 발송 완료 to={}", to);
        } catch (Exception e) {
            log.warn("이메일 발송 실패 to={} error={}", to, e.getMessage());
        }
    }
}
