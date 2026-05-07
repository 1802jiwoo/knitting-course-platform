# 버그 수정 규칙

## Bug Fix Log 규칙

**작성 형식**
- 증상: 어떤 문제가 발생했는지
- 원인: 왜 발생했는지 분석
- 수정 내용: 어떻게 해결했는지

**규칙**
- 모든 버그는 반드시 기록
- 단순 실수도 기록 대상
- 해결 후에도 로그는 삭제하지 않음

---

# 버그 수정 이력

---

## BUG-001: Spring Security AutoConfiguration 클래스 미발견 (컴파일 오류)

**증상**
- `./gradlew build` 시 컴파일 실패
- `SecurityAutoConfiguration`, `UserDetailsServiceAutoConfiguration` cannot find symbol

**원인**
- Spring Boot 4.x에서 security auto-configuration 클래스의 패키지가 변경됨
  - 구 (Spring Boot 3.x): `org.springframework.boot.autoconfigure.security.servlet.*`
  - 신 (Spring Boot 4.x): `org.springframework.boot.security.autoconfigure.*`
- 또한 `spring-security-crypto` 단독 사용 시 `spring-security-config`가 없어 `SecurityFilterChain`/`HttpSecurity` 사용 불가

**수정 내용**
- `build.gradle`: `spring-security-crypto:6.4.5` → `spring-boot-starter-security` (버전 BOM 관리)
- `KnittingCoursePlatformApplication.java`: import 경로 수정
  ```java
  import org.springframework.boot.security.autoconfigure.SecurityAutoConfiguration;
  import org.springframework.boot.security.autoconfigure.UserDetailsServiceAutoConfiguration;
  ```
- `Question.java`: `@Builder.Default` 추가 (`answers` 필드 Lombok 경고 제거)

---

## BUG-002: POST /api/auth/signup HTTP 500 (Spring Security 자동 설정 간섭)

**증상**
- `POST /api/auth/signup` 요청 시 HTTP 500 반환
- 응답 바디: `{"message":"서버 오류가 발생했습니다."}`
- `GET /api/lectures`는 정상 200 응답

**원인**
- `spring-security-crypto` → `spring-security-core` 전이 의존 → `DefaultAuthenticationEventPublisher` classpath 탑재
- Spring Boot가 `SecurityAutoConfiguration`을 자동 활성화, 기본 보안 필터 체인 구성
- `SecurityFilterChain` 미정의 상태에서 모든 요청에 인증 요구 (401/500 혼재)
- `GlobalExceptionHandler.handleGeneral()`에 로깅 없어 실제 예외 확인 불가

**수정 내용**
- `build.gradle`: `spring-security-crypto:6.4.5` → `spring-boot-starter-security`
- `KnittingCoursePlatformApplication.java`: `SecurityAutoConfiguration`, `UserDetailsServiceAutoConfiguration` exclude
- `SecurityConfig.java`: `SecurityFilterChain` 추가 (CSRF 비활성화, 세션 Stateless, 전체 permitAll)
- `GlobalExceptionHandler.java`: `handleGeneral()`에 `log.error("Unhandled exception", e)` 추가

---

## BUG-003: 강의 등록/수정 - 설명 입력 후 등록 버튼 미활성화

**증상**
- 제목과 설명을 모두 입력해도 강의 등록/저장 버튼이 비활성화 상태 유지
- 강의 유형 라디오 버튼을 탭하면 그때서야 버튼이 활성화됨

**원인**
- `LectureCreatePage`, `LectureEditPage`의 `_descCtrl` TextField에 `onChanged` 콜백이 없어 설명 입력 시 `setState`가 호출되지 않음
- `_canSubmit` 재평가가 라디오 버튼 탭 시점까지 지연됨

**수정 내용**
- `lecture_create_page.dart`, `lecture_edit_page.dart`: `_descCtrl` TextField에 `onChanged: (_) => setState(() {})` 추가

---

## BUG-004: 강의 수정 페이지 - 기존 썸네일 미표시

**증상**
- 강의 수정 페이지 진입 시 썸네일 영역이 빈 상태(아이콘+텍스트)로 표시됨
- 기존 등록된 썸네일이 보이지 않아 변경 여부 판단 불가

**원인**
- `MyLectureListResponse`에 `thumbnailUrl` 필드가 없어 프론트로 전달되지 않음
- `InstructorLecture` 엔티티에 `thumbnailUrl` 필드 미존재
- `LectureEditPage` 썸네일 영역이 `_thumbnailBytes`(새로 선택한 이미지)만 체크하고 기존 URL은 미사용

**수정 내용**
- `MyLectureListResponse.java`: `thumbnailUrl` 필드 추가
- `instructor_lecture.dart`: `thumbnailUrl` nullable 필드 추가
- `instructor_lecture_model.dart`: JSON 파싱 추가
- `lecture_edit_page.dart`: `_thumbnailBytes == null`이고 `thumbnailUrl != null`이면 기존 썸네일 `Image.network`으로 표시, 탭 시 교체 가능

---

## BUG-005: 파트 관리 - YouTube 영상 시간 가져오기 웹에서 실패

**증상**
- 정상적인 YouTube URL 입력 후 "시간 가져오기" 버튼 클릭 시 항상 실패
- "영상 시간을 가져오지 못했습니다: 직접 입력해 주세요" snackbar 표시

**원인**
- `youtube_explode_dart` 패키지가 YouTube API에 직접 HTTP 요청
- Flutter Web 환경에서는 모든 HTTP 요청이 브라우저를 통해 전송되어 CORS 정책에 의해 차단됨
- 앱(Android/iOS)에서는 정상 동작

**수정 내용**
- `part_manage_page.dart`: `kIsWeb` 조건으로 웹에서는 "시간 가져오기" 버튼 미노출 처리
- 웹 사용 시 재생 시간을 직접 입력해야 함

---

## BUG-006: 파트 수정 다이얼로그 - 기존 URL/재생 시간 미표시

**증상**
- 파트 수정 클릭 시 제목은 pre-fill되나 YouTube URL과 재생 시간이 빈 칸으로 표시됨

**원인**
- `GET /api/lectures/{lectureId}/parts` 응답 DTO인 `LecturePartResponse`에 `youtubeUrl`, `duration` 필드가 없어 프론트로 전달되지 않음
- `Video`는 `LecturePart`와 별도 엔티티로 분리되어 있으나 응답에 포함되지 않음

**수정 내용**
- `LecturePartResponse.java`: `youtubeUrl`, `duration` 필드 추가, `from()` 메서드에서 `part.getVideo()`로 조회 후 포함