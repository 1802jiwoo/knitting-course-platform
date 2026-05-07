# LoopLearn Project

## Language Rule
- 모든 설명은 **한국어**, 코드명은 변경하지 않음

---

## Stack
- Frontend: Flutter (Clean Architecture + Provider)
- Backend: Spring Boot + MySQL

---

## Docs
| 목적 | 경로 | 포함된 세부 규칙 |
|------|------|----------------|
| 버그 기록 | /docs/p2/bugfix_log.md | Bug Fix 작성 형식·규칙 |
| 프로젝트 상태 | /docs/p2/plans/project_status.md | Backend 작업 프로세스, 상태 기호 기준, 멀티 작업 규칙, 우선순위 기준 |
| 세션 임시 저장 | /docs/p2/session_checkpoint.md | Session Checkpoint 저장·삭제·복구 흐름 |

---

## Development Phase
- P1: 학습 기능 / P2: 인증·서버 연동 / P3: 확장·최적화

## Domain Rules
- Lecture / Part / Pattern 중심 구조
- Tag 기반 분류 시스템

---

## Commands

| 명령 | 동작 |
|------|------|
| `claude-code run front` | 프론트 작업 1개 수행 |
| `claude-code run backend` | 백엔드 작업 1개 수행 |
| `claude-code run next` | 전체 우선순위 최상위 작업 1개 선정 |

**공통 규칙**
1. 실행 전 project_status.md 확인
2. 선택된 작업을 먼저 사용자에게 보고
3. 사용자 OK 이후에만 코드 작성 시작
4. 작업 완료 후 project_status.md 상태 업데이트

**작업 선택 우선순위**: [⁓] 진행 중 → [ ] 미시작 / 의존성 → 핵심 기능 → 영향도 → 기타

> `next`는 선정만 하고 자동 시작 금지

---

## Key Rules (상세 규칙 위치 → /docs/p2/plans/project_status.md 참조)

| 규칙 | 한 줄 요약 |
|------|-----------|
| Project Status | 모든 기능 변경 시 업데이트 필수. 상태: [✓] [⁓] [ ] |
| Backend 작업 | 코드 리뷰 보고 → 서버 URL 확인 → 사용자 OK → 개발 완료 후 API 주소·테스트 예제 제공 → 사용자 직접 테스트 → 결과 보고 → 최종 OK |
| Bug Fix | 문제 발생 시 bugfix_log.md에 즉시 기록 (증상 / 원인 / 수정 내용) |
| Session Checkpoint | 위험 감지 시 checkpoint 저장 → 작업 중단 → 해결 후 bugfix_log 이관 → checkpoint 삭제 |

**Session 자동 저장 트리거**: token·cost 80% / message limit 90% / 세션 리셋·타임아웃 1시간 이내 / 안정성 낮다고 판단 시