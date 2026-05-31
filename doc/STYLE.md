# Loveloop AI — 사용자웹 스타일 가이드 (STYLE.md)

> 버전 1.0 · 2026-05-31 · 대상: `loveloop-user` 프로토타입
> 디자인 시스템 기반: 벤토(Bento) + 글래스(Liquid Glass), 모바일 우선

---

## 0. 설계 철학

Loveloop 사용자웹은 정서적 교류를 제공하되 **건강한 사용을 유도**하는 것을 최우선으로 한다.
디자인은 이 원칙을 시각적으로 강화한다.

| 원칙 | 디자인 반영 |
|---|---|
| 건강한 사용 유도 | 무한 스크롤 대신 "오늘의 피드 완료", 웰빙 넛지 카드 |
| 가치 기반 과금 | 결제 CTA에 산출물 명시, 쿨다운·일일 상한 고지 |
| 상호 존중 | 페르소나 톤은 지지·존중형, 통제·집착 표현 금지 |
| 동의 기반 기억 | 보관함에서 전체 열람·삭제 가능 |
| 자산화 금지 | 소장 현황은 "자산이 아니에요" 명시, 시세·등락 미표기 |

---

## 1. 레이아웃 구조

모바일 디바이스 프레임(414px) 안에 3개 영역을 세로 배치한다.

```
┌─────────────────────────┐
│  글래스 톱바 (top)        │  ← 페르소나 아바타/이름/상태 + 웰빙 바로가기
├─────────────────────────┤
│                         │
│  스크린 (screen)         │  ← 6개 view 전환, 벤토 그리드
│  - 홈 / 대화 / 페르소나   │
│  - 웰빙 / 보관함 / 스토어 │
│                         │
├─────────────────────────┤
│  글래스 탭바 (tabbar)     │  ← 5개 탭
└─────────────────────────┘
```

- 기준 너비: 414px (iPhone Pro), 페이지 컨테이너 max 480px
- 데스크톱에선 메시 그라데이션 무대 위 중앙 정렬

---

## 2. 색상 토큰

```css
/* Primary — Apple Blue */
--color-primary:#0066CC; --color-primary-hover:#0077ED;
--color-primary-focus:#0071E3; --color-primary-dark:#4DA3FF;

/* Surface */
--color-canvas:#FFFFFF; --color-parchment:#F5F5F7;
--color-pearl:#FAFAFC; --color-surface2:#ECEDEF;

/* Ink (텍스트) */
--color-ink:#1D1D1F; --color-muted-48:#7A7A7A; --color-muted-80:#333333;

/* 구분선 */
--color-divider:#F0F0F0; --color-hairline:#E0E0E0;

/* Semantic */
--color-danger:#D70015; --color-hot:#FF4500; --color-rising:#FF6B35;
```

원칙: 컬러는 액션·강조에만. 본문 텍스트는 회색 톤. primary를 본문 텍스트에 쓰지 않는다.

---

## 3. 글래스 표면 위계

| 레벨 | 배경 opacity | blur | 사용처 |
|---|---|---|---|
| 헤로 | 0.70→0.45 (gradient) | 18px | 페이지 상단 인사/요약 (`.cell--hero`) |
| 메인 | 0.55 | 16px | 콘텐츠 카드 (`.cell`, `.feed-card`) |
| 중첩 | 0.45 | 10px | 카드 안 항목 |
| 약함 | 0.40 | 10px | 빈 상태, 피드 종료 카드 |

규칙: 부모보다 자식이 더 옅게 — 같은 opacity면 위계가 평면화된다(안티패턴).

배경(메시 그라데이션): 4개 radial-gradient를 겹쳐 톤을 만들고, 글래스 카드 위로 색이 비치게 한다. 디바이스 내부에도 동일 메시를 적용한다.

---

## 4. 벤토 그리드

```css
.bento{display:grid;grid-template-columns:1fr 1fr;gap:12px;opacity:0;
  transition:opacity .35s cubic-bezier(.4,0,.2,1)}
.bento.mounted{opacity:1}   /* ⚠️ mounted 없으면 영구 opacity:0 (빈 화면 버그) */
```

셀 종류: `.cell`(1×1) · `.cell--hero`(풀폭) · `.cell--stat`(통계) · `.cell--cta`(primary 배경) · `.cell--full`(풀폭).

---

## 5. 컴포넌트

- **버튼** `.btn` / `.btn--primary`(파랑) / `.btn--ghost`(테두리) / `.btn--danger`(빨강) / `.btn--sm` / `.btn--block`
- **칩** `.glass-pill`(히어로 위 반투명), `.pl-tag`(페르소나 해시태그)
- **통계 텍스트** 그라데이션 클립(`-webkit-text-fill-color:transparent`)
- **토글** 48×22px, OFF `#E0E0E0` / ON `#34C759`(설정) 또는 primary
- **대화 버블** AI=글래스 흰색(좌하단 직각), 사용자=블루 그라데이션(우하단 직각)

---

## 6. 화면별 콘텐츠 배열

| view | 핵심 구성 |
|---|---|
| 홈 | 헤로(오늘의 안부) · 오늘 사용/기억 stat · **주간 시간+스파크라인** · 피드 카드 3 · 피드 종료 휴식 카드 |
| 대화 | 가드레일 배너 · 글래스 버블 · 음성/전송 |
| 페르소나 | 카드 5종 (아바타·스타일칩·대표대사·**소개·해시태그**·함께하기) |
| 웰빙 | 헤로 · 사용/대화/야간 stat · 휴식 넛지 · 사용 추이 바 · 사용 설정 토글 |
| 보관함 | 동의 안내 · 기억 항목(열람·삭제) · 동의 관리/전체 삭제 |
| 스토어 | 가드 배너 · **내 소장(자산 아님)** · 상품 3종 · 충전보너스/가챠/압박 배제 고지 |

---

## 7. 타이포그래피

```css
font-family:-apple-system,BlinkMacSystemFont,'Apple SD Gothic Neo','Pretendard','Noto Sans KR',sans-serif;
```

| 용도 | size | weight | letter-spacing |
|---|---|---|---|
| 헤로 타이틀 | 28px | 800 | -0.03em |
| 페이지 타이틀 | 22px | 700 | -0.02em |
| 카드 타이틀 | 16px | 600 | 0 |
| 본문 | 14px | 400 | 0 |
| 보조 | 12px | 400 | 0 |

---

## 8. 마이크로 인터랙션

- transition 0.18s / 0.35s, transform 거리 1~2px (과한 모션 금지)
- 카드 tap: `translateY(-1px)` 또는 `scale(.99)`
- view 전환: opacity + translateY(6px) 페이드

---

## 9. 안티패턴 (금지)

- ❌ 글래스 위 글래스 (위계 소멸)
- ❌ primary 색을 본문 텍스트에
- ❌ 무한 스크롤 / 정서 고조 시점 결제 버튼
- ❌ 코인 시세·등락률 표기 (자산화)
- ❌ 충전 보너스·가챠·카운트다운 압박
- ❌ 통제·집착·고립 유도 페르소나 대사

---

## 10. 안전 디자인 체크리스트

- [ ] 대화 화면에 가드레일 배너가 있는가
- [ ] 피드는 종료 지점 + 휴식 제안이 있는가
- [ ] 결제 모달에 쿨다운·일일 상한 고지가 있는가
- [ ] 소장은 "자산 아님"으로 표기되는가
- [ ] 페르소나 대사가 모두 존중형인가
- [ ] 기억 항목을 사용자가 삭제할 수 있는가
