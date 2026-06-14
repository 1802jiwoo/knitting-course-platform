package com.example.knitting_course_platform.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
public class DiscordWebhookService {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${discord.webhook.url}")
    private String webhookUrl;

    public void sendApproved(Long applicationId, Long userId, String nickname) {
        String body = """
            {
              "embeds": [{
                "title": "✅ 강사 승인",
                "color": 3066993,
                "fields": [
                  {"name": "신청 ID", "value": "#%d", "inline": true},
                  {"name": "사용자", "value": "%s (ID: %d)", "inline": true}
                ]
              }]
            }
            """.formatted(applicationId, nickname, userId);
        send(body);
    }

    public void sendRejected(Long applicationId, Long userId, String nickname) {
        String body = """
            {
              "embeds": [{
                "title": "❌ 강사 거절",
                "color": 15158332,
                "fields": [
                  {"name": "신청 ID", "value": "#%d", "inline": true},
                  {"name": "사용자", "value": "%s (ID: %d)", "inline": true}
                ]
              }]
            }
            """.formatted(applicationId, nickname, userId);
        send(body);
    }

    private void send(String jsonBody) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            restTemplate.postForEntity(webhookUrl, new HttpEntity<>(jsonBody, headers), String.class);
        } catch (Exception e) {
            log.warn("Discord 알림 전송 실패: {}", e.getMessage());
        }
    }
}
