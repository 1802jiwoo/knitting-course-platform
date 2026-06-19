# P3 Project Status

**단계:** P3 – 운영형 / 외부연동 / 관측성  
**상태 기호:** [✓] 완료 / [⁓] 진행 중 / [ ] 미시작

---

## 작업 선택 우선순위

1. 보안 (운영 전 필수)
2. 운영 안정성 (로그·모니터링)
3. 성능 최적화
4. 외부 연동
5. 결제 모듈

---

## 완료된 작업

### [✓] DB 인덱스 최적화 (Performance)
- [✓] `idx_lecture_status` — lecture.status (searchApproved full-scan 제거)
- [✓] `idx_enrollment_user_lecture` — enrollment(user_id, lecture_id) UNIQUE (중복 수강 DB 보호 + 복합 조회)
- [✓] `idx_enrollment_user_created` — enrollment(user_id, created_at) (내 강의 목록 정렬)
- [✓] `idx_question_lecture_created` — question(lecture_id, created_at) (강의별 Q&A 목록 정렬)
- [✓] `idx_app_user_status` — instructor_application(user_id, status) (강사 신청 중복 체크)
- [✓] `idx_app_status_created` — instructor_application(status, created_at) (관리자 신청 목록)
- [✓] Entity @Index 어노테이션 추가 (Lecture, Enrollment, Question, InstructorApplication)
- [✓] ddl-auto=validate 통과 확인

### [✓] 보안 강화 (Security Hardening)
- [✓] Security Headers 추가 (X-Content-Type-Options, X-Frame-Options, X-XSS-Protection)
- [✓] bcrypt DoS 방어 – password @Size(max=100) 추가 (SignUpRequest, LoginRequest, ChangePasswordRequest)
- [✓] 회원가입 닉네임 @Pattern 추가 (특수문자 차단, ProfileUpdateRequest와 일관성)
- [✓] 이미지 MIME type 검증 (jpg/png/gif 외 업로드 차단)
- [✓] lectureType 허용값 검증 (STITCH_BASICS/PROJECT_CLASS/PATTERN 외 거부)
- [✓] SQL 인젝션 검토 – native query 없음 확인, JPA parameterized query 사용 중 → 안전

### [✓] 관리자 강의 승인 기능 (Admin Lecture Approval)
- [✓] `Lecture.approve()`/`reject()` 추가 (PENDING → APPROVED/REJECTED)
- [✓] `GET /api/admin/lectures` — 검토 대기(PENDING) 강의 목록 (ADMIN 권한)
- [✓] `POST /api/admin/lectures/{lectureId}/approve` / `reject`
- [✓] 프론트 `AdminPage`에 "강의 승인" 탭 추가 (강사 신청 관리 탭과 동일 UX)
- [✓] EC2(`43.203.212.14`) 백엔드 jar 재배포 + 프론트 웹 빌드 배포 완료

---

## 진행 중인 작업

없음

---

## 향후 작업

### [✓] 운영 로그 + 스케쥴러 (Operational Logging)
- [✓] logback-spring.xml — 콘솔(개발) / 파일 롤링(운영/prod) 환경 분리, ERROR 전용 파일, 30일 보관
- [✓] 서비스 로그 추가 — AuthService(회원가입·로그인 성공/실패), EnrollmentService(수강 신청·취소), AdminService(강사 승인·거절)
- [✓] 스케쥴러 TokenCleanupScheduler — 매일 자정 만료 RefreshToken 일괄 삭제 (@Scheduled)
- [✓] RefreshTokenRepository.deleteAllExpiredBefore 추가
- [✓] @EnableScheduling 적용

---

### ⚡ 성능 최적화 (Performance)
| 항목 | 예상 소요 | 비고 |
|------|----------|------|
| [ ] N+1 쿼리 해결 (Fetch Join / @EntityGraph) | 1시간 | LectureService, EnrollmentService 위주 |
| [ ] 프론트 렌더링 최적화 (리스트 Lazy Loading 등) | 1.5시간 | Flutter ListView.builder 활용 |
| [ ] 코드 리팩토링 – 중복 서비스 로직 정리 | 1시간 | |

---

### [✓] 외부 연동 — Discord Webhook
- [✓] DiscordWebhookService 구현 (강사 승인 ✅ 초록 / 거절 ❌ 빨강 embed 메시지)
- [✓] AdminService 승인·거절 시 자동 호출
- [✓] 전송 실패 시 서버 중단 없이 WARN 로그만 기록 (장애 격리)

### 🔗 외부 연동 (External Integration) — 잔여
| 항목 | 예상 소요 | 비고 |
|------|----------|------|
| [⁓] 이메일 알림 – 강사 승인/거절 시 SMTP 발송 | 1시간 | 코드(EmailService, Naver SMTP)만 작성되어 있고 실제 발송 테스트 안 됨 — 정상 작동 미확인 상태. 발표/시연에서 제외 |
| [ ] 스케쥴러 – 매주 수강 통계 집계 | 1.5시간 | @Scheduled |

---

### 🚀 배포 (Deployment)
| 항목 | 예상 소요 | 비고 |
|------|----------|------|
| [ ] GitHub Actions CI – 빌드 자동화 | 1시간 | main 브랜치 push 시 자동 빌드 |
| [ ] GitHub Actions CD – EC2 자동 배포 | 1.5시간 | SSH 배포 |
| [ ] EC2 HTTPS 설정 (Nginx + Let's Encrypt) | 1시간 | |

---

### 💳 결제 모듈 (Payment) — 난이도 높음
| 항목 | 예상 소요 | 비고 |
|------|----------|------|
| [⁓] Toss Payments 결제 연동 | 1일+ | 백엔드 API(`/api/payments/confirm`)는 동작하나, 정상적으로 동작 안 함으로 처리 — 발표/시연에서 제외 |
| [ ] 결제 내역 조회 (프론트 + 백엔드) | 3시간 | |
