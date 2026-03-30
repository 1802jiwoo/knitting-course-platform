# LoopLearn API 엔드포인트 명세서

**프로젝트명:** LoopLearn  
**버전:** 1.0 (P1)  
**작성일:** 2026-03-12  

---

## 1. 개요

본 문서는 LoopLearn P1 단계의 REST API 엔드포인트를 정의한다.
클라이언트(Flutter Web)와 서버(Spring Boot) 간의 데이터 통신을 위한 API 구조를 설명한다.

### Base URL

```
/api
```

### 응답 형식

모든 API 응답은 JSON 형식을 사용한다.

> ※ P1 단계에서 구현하지 않는 기능(답변, 수강관리, 로그인 등)의 API는 포함하지 않는다.

---

## 2. 강의 (Lectures)

### 강의 목록 조회

강의 목록을 조회한다.

```
GET /api/lectures
```

#### Query Parameters

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| page | int | N | 페이지 번호 |
| size | int | N | 페이지 크기 |
| title | string | N | 강의 제목 검색 |
| tag | string | N | 태그 검색 (단일 태그) |
| instructor | string | N | 강사 이름 검색 |

#### Response

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

---

### 강의 상세 조회

특정 강의의 상세 정보를 조회한다.

```
GET /api/lectures/{lectureId}
```

#### Response

```json
{
  "lectureId": 1,
  "title": "강아지 인형 만들기",
  "description": "코바늘 인형 강의",
  "instructor": "지우",
  "lectureType": "PROJECT_CLASS",
  "tags": ["인형", "초보"]
}
```

---

## 3. 강의 파트 (Lecture Parts)

### 강의 파트 목록 조회

강의에 포함된 파트 목록을 조회한다.

```
GET /api/lectures/{lectureId}/parts
```

#### Response

```json
[
  {
    "partId": 1,
    "title": "머리 만들기",
    "order": 1
  }
]
```

---

## 4. 영상 (Video)

### 파트 영상 조회

특정 파트에 해당하는 영상을 조회한다.

```
GET /api/parts/{partId}/video
```

#### Response

```json
{
  "videoId": 1,
  "youtubeUrl": "https://youtube.com/xxxx",
  "duration": 1200
}
```

---

## 5. 도안 (Pattern)

### 강의 단위 도안 조회

강의 유형이 "도안(Pattern)"인 강의의 전체 도안을 조회한다.

```
GET /api/lectures/{lectureId}/patterns
```

#### Response

```json
[
  {
    "patternId": 1,
    "rowNumber": 1,
    "patternText": "sc 6 (6)"
  }
]
```

---

### 파트 단위 도안 조회 (영상 연동)

특정 파트의 영상 재생 시간에 연동된 도안을 조회한다.

```
GET /api/parts/{partId}/patterns
```

#### Response

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

---

## 6. 도안 기호 (Pattern Symbol)

### 도안 기호 목록 조회

전체 도안 기호 및 설명 목록을 조회한다.

```
GET /api/pattern-symbols
```

#### Response

```json
[
  {
    "symbolId": 1,
    "symbol": "sc",
    "description": "짧은뜨기"
  },
  {
    "symbolId": 2,
    "symbol": "inc",
    "description": "늘림"
  }
]
```

---

### 도안 기호 단건 조회

특정 기호의 설명을 조회한다. 사용자가 도안에서 기호를 클릭할 때 호출된다.

```
GET /api/pattern-symbols/{symbol}
```

#### Path Parameters

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| symbol | string | Y | 기호 문자 (예: sc, inc, dec) |

#### Response

```json
{
  "symbolId": 1,
  "symbol": "sc",
  "description": "짧은뜨기"
}
```

---

## 7. 태그 (Tags)

### 태그 목록 조회

전체 태그 목록을 조회한다.

```
GET /api/tags
```

#### Response

```json
[
  "인형",
  "가방",
  "옷"
]
```

---

## 8. 수강 (Enrollment)

> P1 단계에서는 로그인 기능이 없으므로 수강 정보는 클라이언트(브라우저 로컬 스토리지)에서 관리한다.  
> 아래 API는 P2 이후 서버 연동 시 사용하기 위한 명세이며, P1에서는 구현하지 않는다.

### 수강 신청

강의를 수강 신청한다.

```
POST /api/enrollments
```

#### Request Body

```json
{
  "lectureId": 1
}
```

#### Response

```json
{
  "enrollmentId": 1,
  "lectureId": 1,
  "progress": 0,
  "createdAt": "2026-03-12T10:00:00"
}
```

---

### 수강 중인 강의 목록 조회

수강 신청한 강의 목록과 진도율을 조회한다.

```
GET /api/enrollments
```

#### Response

```json
[
  {
    "enrollmentId": 1,
    "lectureId": 1,
    "title": "강아지 인형 만들기",
    "instructor": "지우",
    "lectureType": "PROJECT_CLASS",
    "tags": ["인형", "초보"],
    "progress": 60,
    "totalParts": 5,
    "completedParts": 3
  }
]
```

---

### 수강 취소

수강 중인 강의를 취소한다.

```
DELETE /api/enrollments/{enrollmentId}
```

#### Response

```
204 No Content
```

---

### 파트 시청 완료 처리

특정 파트 시청 완료 시 진도를 업데이트한다.

```
POST /api/enrollments/{enrollmentId}/complete-part
```

#### Request Body

```json
{
  "partId": 1
}
```

#### Response

```json
{
  "enrollmentId": 1,
  "completedParts": 2,
  "totalParts": 5,
  "progress": 40
}
```

---

## 9. 질문 (Questions)

### 질문 작성

강의에 대한 질문을 작성한다.

```
POST /api/questions
```

#### Request Body (multipart/form-data)

| 필드 | 타입 | 필수 | 제약 조건 |
|------|------|------|---------|
| lectureId | int | Y | - |
| title | string | Y | 최대 100자 |
| content | string | Y | 최대 1000자 |
| image | file | N | 1장, 최대 5MB, jpg/png/gif |

---

### 질문 목록 조회

특정 강의에 등록된 질문 목록을 조회한다.

```
GET /api/lectures/{lectureId}/questions
```

#### Response

```json
[
  {
    "questionId": 1,
    "title": "3단에서 막혔어요",
    "createdAt": "2026-03-12T10:00:00"
  }
]
```

---

### 질문 상세 조회

특정 질문의 상세 내용을 조회한다.

```
GET /api/questions/{questionId}
```

#### Response

```json
{
  "questionId": 1,
  "lectureId": 1,
  "title": "3단에서 막혔어요",
  "content": "여기서 어떻게 해야 하나요?",
  "imageUrl": "https://...",
  "createdAt": "2026-03-12T10:00:00"
}
```

---

## 10. API 구조 요약

```
/api
 ├ lectures
 │  ├ GET  /lectures                        강의 목록 조회 (title, tag, instructor 검색)
 │  ├ GET  /lectures/{id}                   강의 상세 조회
 │  ├ GET  /lectures/{id}/parts             강의 파트 목록 조회
 │  ├ GET  /lectures/{id}/patterns          강의 단위 도안 조회
 │  └ GET  /lectures/{id}/questions         질문 목록 조회
 │
 ├ parts
 │  ├ GET  /parts/{id}/video                파트 영상 조회
 │  └ GET  /parts/{id}/patterns             파트 단위 도안 조회 (영상 연동)
 │
 ├ pattern-symbols
 │  ├ GET  /pattern-symbols                 도안 기호 목록 조회
 │  └ GET  /pattern-symbols/{symbol}        도안 기호 단건 조회
 │
 ├ enrollments                              ※ P2 이후 서버 연동 예정 (P1: 로컬 스토리지)
 │  ├ POST /enrollments                     수강 신청
 │  ├ GET  /enrollments                     수강 중인 강의 목록 조회 (진도율 포함)
 │  ├ DELETE /enrollments/{id}              수강 취소
 │  └ POST /enrollments/{id}/complete-part  파트 시청 완료 처리
 │
 ├ questions
 │  ├ POST /questions                       질문 작성
 │  └ GET  /questions/{id}                  질문 상세 조회
 │
 └ tags
    └ GET  /tags                            태그 목록 조회
```
