# LoopLearn — backend/CLAUDE.md

## 기술 스택
- **Framework:** Spring Boot
- **DB:** MySQL
- **API 형식:** REST / JSON
- **Base URL:** `/api`

## DB 스키마 (ERD 요약)

| 테이블 | 주요 컬럼 | 비고 |
|--------|----------|------|
| `lecture` | lecture_id, title, description, lecture_type, instructor_name, created_at, user_id(FK) | lecture_type: STITCH_BASICS / PROJECT_CLASS / PATTERN |
| `lecture_part` | part_id, lecture_id(FK), title, order_no | 강의 구성 파트 |
| `video` | video_id, part_id(FK), youtube_url, duration | 파트당 영상 1개 |
| `lecture_pattern` | pattern_id, lecture_id(FK), row_num, pattern_text | PATTERN 유형 강의 전용 |
| `part_pattern` | pattern_id, part_id(FK), start_time, end_time, row_num, pattern_text | 영상 시간 연동 도안 |
| `pattern_symbol` | symbol_id, symbol, description | 예: sc → 짧은뜨기 |
| `tag` | tag_id, tag_name | |
| `lecture_tag` | lecture_id(FK), tag_id(FK) | 다대다 조인 테이블 |
| `question` | question_id, user_id(FK), lecture_id(FK), title, content, image_url, created_at | user_id nullable (P1: 익명) |
| `answer` | answer_id, question_id(FK), instructor_id(FK), content, created_at | P2 구현 예정 |
| `enrollment` | enrollment_id, user_id(FK), lecture_id(FK), completed_parts, total_parts, progress, created_at | P1: 미사용(로컬스토리지), P2 연동 |

## P1 구현 API 엔드포인트

### 강의
```
GET  /api/lectures                        강의 목록 (page, size, title, tag, instructor 쿼리 파라미터)
GET  /api/lectures/{lectureId}            강의 상세
GET  /api/lectures/{lectureId}/parts      파트 목록
GET  /api/lectures/{lectureId}/patterns   강의 단위 도안 (PATTERN 유형)
GET  /api/lectures/{lectureId}/questions  질문 목록
```

### 파트
```
GET  /api/parts/{partId}/video            파트 영상 조회
GET  /api/parts/{partId}/patterns         파트 단위 도안 (영상 시간 연동)
```

### 도안 기호
```
GET  /api/pattern-symbols                 전체 기호 목록
GET  /api/pattern-symbols/{symbol}        기호 단건 조회 (예: /api/pattern-symbols/sc)
```

### 태그
```
GET  /api/tags                            전체 태그 목록
```

### 질문
```
POST /api/questions                       질문 작성 (multipart/form-data)
GET  /api/questions/{questionId}          질문 상세
```

### 답변 (P1: 조회만)
```
GET  /api/questions/{questionId}/answer   답변 조회
```

### 수강 (P2 구현 예정 — P1 미구현)
```
POST   /api/enrollments
GET    /api/enrollments
DELETE /api/enrollments/{enrollmentId}
POST   /api/enrollments/{enrollmentId}/complete-part
```

## 응답 형식 예시

### 강의 목록 `GET /api/lectures`
```json
[
  {
    "lectureId": 1,
    "title": "강아지 인형 만들기",
    "instructor": "지우",
    "lectureType": "PROJECT_CLASS",
    "tags": ["인형", "초보"]
  }
]
```

### 파트 단위 도안 `GET /api/parts/{partId}/patterns`
```json
[
  {
    "patternId": 1,
    "startTime": 20,
    "endTime": 40,
    "rowNumber": 1,
    "patternText": "sc sc inc"
  }
]
```

### 질문 작성 `POST /api/questions` (multipart/form-data)
| 필드 | 타입 | 필수 | 제약 |
|------|------|------|------|
| lectureId | int | Y | |
| userId | int | N | 없으면 익명 |
| title | string | Y | 최대 100자 |
| content | string | Y | 최대 1000자 |
| image | file | N | 1장, 최대 5MB, jpg/png/gif |

## 비기능 요구사항
- 강의 목록·검색·상세 조회 응답: **2초 이내**
- 질문 작성 응답: **3초 이내**
- P1: 인증·인가 없음 (모든 API 공개)
- 이미지 업로드: 익명 처리

## 주의사항
- `enrollment` 테이블은 P1에서 사용하지 않음. 스키마만 준비.
- `question.user_id`는 P1에서 nullable (익명 질문).
- `lecture_type` 값은 반드시 `STITCH_BASICS` / `PROJECT_CLASS` / `PATTERN` 중 하나.
- `part_pattern.start_time` / `end_time` 단위는 **초(seconds)**.
- `video.youtube_url`은 YouTube 영상 ID만 저장 (전체 URL 아님).
