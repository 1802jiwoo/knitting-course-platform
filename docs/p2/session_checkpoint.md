## Session Checkpoint 규칙

**자동 저장 트리거** (하나라도 해당되면 즉시 저장 후 작업 중단)
- token·cost usage 80% 이상
- message limit 90% 이상
- 세션 리셋·타임아웃 1시간 이내
- limit·cost·token·budget 관련 경고 발생
- 추가 진행 시 안정성이 낮다고 판단되는 경우

**저장 규칙**
- 확인된 사실만 기록
- 추측은 Hypothesis로 분리
- 다음 실행 가능한 단계까지 포함
- 추가 디버깅·추론 금지 (저장만 수행)

**삭제 기준**
- 사용자에게 해결 완료 승인(OK)을 받은 경우
- 해당 이슈가 bugfix_log.md로 이전 완료된 경우

**정리 흐름**
1. 위험 감지 → session_checkpoint.md 저장
2. 작업 중단
3. 세션 재시작 시 해당 파일로 복구
4. 해결 완료 시 bugfix_log.md로 이관
5. session_checkpoint.md 내용 삭제
