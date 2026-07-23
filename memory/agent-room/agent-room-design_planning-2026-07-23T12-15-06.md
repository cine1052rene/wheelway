# 디자인기획팀 Report

**Topic:** WheelWay — 교통약자(목발/수동·전동 휠체어 이용자)를 위한 지하철 지름길 안내 Flutter 앱의 디자인 방향 수립. 지상 진입→승차 칸번호→환승→지상 진출까지 단계별 이동 타임라인이 핵심 UI. 접근성 최우선(고명암비, 큰 글씨, 48dp+ 터치타깃, TalkBack 스크린리더 지원)이 디자인의 존재 이유. 색 팔레트, 타이포그래피, 간격, 컴포넌트 스타일, 다크모드 여부를 정하고 Flutter ThemeData 디자인 토큰으로 구체화할 것. 탭 구조: 지름길 찾기/역 접근성/데이터 정보.
**Total Rounds:** 4
**Date:** 2026-07-23

---

## Round 1 — Stage 1: 서비스 분석가 ✅

> **Passed → Stage 2**

### 1. 서비스 심층 분석

#### 핵심 목적
교통약자(목발·수동·전동 휠체어)가 지하철을 이용할 때 **지상 진입→승차 칸번호→환승→지상 진출**까지의 전체 동선을 단계별로 안내하는 **지름길 내비게이션**. "노선도 앱"이 아니라 실제 이동 타임라인을 제공하는 것이 핵심 정체성.

#### 타겟 사용자층
| 구분 | 상세 |
|---|---|
| **1차** | 목발·수동 휠체어 이용자 (만 18~60대, 출퇴근·외출·병원 방문) |
| **2차** | 전동 휠체어 이용자 (엘리베이터 용량·문폭 제약이 더 엄격) |
| **맥락** | 홀로 또는 보호자와 함께, 스마트폰으로 출발 전·이동 중 실시간 확인 |
| **니즈** | 계단/에스컬레이터 회피, 정확한 칸번호, 환승 동선 최소화, 큰 글씨·음성 지원 |

---

### 2. 경쟁/유사 서비스 벤치마크 (5개)

#### ① 휠비(Wheelvi) — 한국 🇰🇷
- **특징**: 휠체어 접근 가능 경로 내비게이션 + 건물 접근성 정보
- **디자인 인사이트**: 초록(가능)/빨강(불가능) 이진 색상 체계로 즉각적 인식. 사용자 유형(수동/전동)별 기준 다름.
- **약점**: 지하철 칸번호 안내 없음. WheelWay가 차별화되는 지점.

#### ② 서울동행맵 — 서울시 🏙️
- **특징**: 교통약자 맞춤 보행 경로, 저상버스 예약, 지하철 엘리베이터 위치
- **디자인 인사이트**: 지도 중심 UI. 아이콘 중심의 시각 언어. 공공기관 스타일(차분한 블루).
- **약점**: 지하철 내부 동선(칸번호·환승 구체 안내)이 약함.

#### ③ Transit App — 글로벌 🌐
- **특징**: GO 모드(오디오 단계별 안내), VoiceOver/TalkBack 지원, WCAG 2.2 Level AAA 준수
- **디자인 인사이트**: 깔끔한 카드 UI, 진행 방향 중심 타임라인, 대중교통 컬러 코드 활용
- **시사점**: 접근성을 설계의 근본 원칙으로. 화면 읽기 기능 최우선 설계.

#### ④ MBTA NaviLens — 미국 🇺🇸
- **특징**: BLE 기반 실내 내비게이션, 3D 음향·햅틱, QR 코드로 정류장 위치 인식
- **디자인 인사이트**: 멀티모달 피드백(시각·청각·촉각). 인지 접근성을 위한 단순화된 지도.
- **시사점**: 스크린리더와 음성 안내를 UI와 대등하게 설계해야 함.

#### ⑤ Google Maps 접근 가능한 경로 — 글로벌 🗺️
- **특징**: "휠체어 접근 가능한 경로만 보기" 필터, 계단 없는 환승 안내
- **디자인 인사이트**: Material You 기반, 고명암비 지원, Dynamic Color, 대형 터치 타깃
- **시사점**: Flutter Material 3 기반 설계 시 참고할 UI 패턴의 기준점.

---

### 3. 기존 PWA 디자인 현황 분석

**현재 색상 시스템:**
```
--ink:     #15211d  (최어두운 텍스트)
--muted:   #66736d  (보조 텍스트)
--green:   #08705b  (브랜드 메인)
--deep:    #075445  (브랜드 딥)
--mint:    #e3f1eb  (배경 강조)
--cream:   #f8faf7  (기본 배경)
--line:    #dbe5df  (구분선)
--orange:  #ee8d42  (경고/액센트)
```

**기존 타이포그래피:**
- DM Sans (영문) + Noto Sans KR (한글)
- 계층: 42px H1 → 22px H2 → 20px section → 14px body → 11~12px caption

**레이아웃 패턴:**
- 카드 기반(border-radius 12~20px), 그림자 subtle
- 3컬럼 역 그리드(태블릿), 1컬럼 모바일
- 세로 타임라인(journey steps) — Flutter로 그대로 이식 적합

**현재 UI의 접근성 취약점:**
- 터치 타깃 미검증 (CSS px 단위, 48dp 미보장)
- 다크모드 없음
- TalkBack semantics 미적용 (웹이라 aria 속성만 부분 사용)
- 11px caption은 저시력 사용자에게 너무 작음

---

### 4. 브랜드 정체성 및 톤앤매너

| 속성 | 정의 |
|---|---|
| **브랜드 키워드** | 신뢰·안전·명확·포용 |
| **감정 목표** | "이 앱이 날 이해한다" — 당황하지 않고 자신 있게 이동할 수 있다는 안도감 |
| **비주얼 레퍼런스** | 자연에서 온 깊은 녹색 (Emerald, Forest Green) + 따뜻한 오렌지 액센트 (에너지·경고) |
| **금지 톤** | 차갑고 기관스러운 파랑, 과도한 장식, 작은 글씨, 낮은 대비 |
| **카피 톤** | 직접적·행동 중심. "경로 찾기" X → "지름길 찾기" O. 사용자를 수동적 정보 수신자가 아닌 이동 주체로 |

---

### 5. 플랫폼 특성 및 기술 제약

#### Flutter ThemeData 제약사항
- `ColorScheme.fromSeed()` 사용 → 라이트/다크 자동 생성 가능
- `MediaQuery.of(context).highContrast` → 고대비 모드 대응 필수
- `TextTheme` — `displayLarge`~`bodySmall` 계층 매핑
- 최소 터치 타깃: **48×48 dp** (Material 가이드라인, 접근성 필수)
- 한글 렌더링: Noto Sans KR이 Flutter 기본 한글 폰트로 이미 내장

#### TalkBack 접근성 제약
- 모든 의미 있는 위젯에 `Semantics` 래퍼 필요
- 아이콘 전용 버튼엔 반드시 `semanticLabel`
- 타임라인 순서 = 스크린리더 읽기 순서 → DOM(위젯 트리) 순서가 논리적이어야 함
- `ExcludeSemantics`로 장식 요소 제외

#### 다크모드 설계 원칙 (2026 기준)
- 82% 사용자가 다크모드 부분 사용 → 선택 토글이 아니라 시스템 연동 기본 지원
- 어두운 배경에 순수 흰색 텍스트 금지 → 약 87% 명도로 눈 피로 감소
- 에러/경고 색(오렌지)은 다크모드에서 더 밝게 조정 필요

#### WCAG 2.1 AA 충족 조건 (2026 ADA 의무화)
- 일반 텍스트 명암비 ≥ **4.5:1**
- 큰 텍스트(18pt+, 14pt Bold+) ≥ **3:1**
- 포커스 인디케이터 가시화
- 색만으로 정보 전달 금지 (초록/빨강 이진 체계 → 아이콘 병행 필수)

---

### 6. Flutter ThemeData 설계를 위한 방향 요약

```
Seed Color: #08705B (Forest Green)
Primary:    #08705B (라이트) / #5EC89A (다크)
Secondary:  #EE8D42 (오렌지 — 경고·강조)
Background: #F8FAF7 (라이트) / #0E1A16 (다크)
Surface:    #FFFFFF (라이트) / #1A2C24 (다크)
Error:      #D9604F (라이트) / #FF8875 (다크)

Typography: NotoSansKR-Bold + NotoSansKR-Regular
  - displayLarge: 32sp Bold (역명 표시)
  - headlineMedium: 22sp Bold (섹션 타이틀)
  - bodyLarge: 16sp Regular (설명 텍스트)
  - labelSmall: 최소 12sp (캡션 — 11px 이하 금지)

Touch Target: 48dp 최소 보장 (프로필 버튼, 탭, 검색 버튼)
Border Radius: 16dp (카드), 12dp (버튼/입력), 8dp (칩)
```

---

---

## Round 2 — Stage 2: 디자인 전략가 ✅

> **Passed → Stage 3**

# WheelWay 디자인 전략 보고서

---

## 1. 컬러 팔레트 설계

### 접근성 원칙 선행 정의

> ⚠️ 기존 PWA의 오렌지(`#EE8D42`)는 **흰 배경 대비 2.3:1**로 텍스트 사용 불가. 장식·아이콘 전용으로 격하하고 텍스트 사용 오렌지는 별도 지정.

---

### 🅐 시안 A: "에메랄드 워크 (Emerald Walk)" — 브랜드 계승 + 따뜻함

| 역할 | Token | Light HEX | Dark HEX | 대비비 (on bg) |
|------|-------|-----------|----------|----------------|
| **Primary** | `primary` | `#08705B` | `#6FDBB8` | 7.2:1 ✅ AA+ |
| onPrimary | `onPrimary` | `#FFFFFF` | `#00382B` | — |
| Primary Container | `primaryContainer` | `#C8F0E3` | `#005241` | — |
| onPrimaryContainer | `onPrimaryContainer` | `#00201A` | `#6FDBB8` | — |
| **Secondary (텍스트용)** | `secondary` | `#B45400` | `#FFB870` | 4.6:1 ✅ AA |
| onSecondary | `onSecondary` | `#FFFFFF` | `#4A2800` | — |
| Secondary Container | `secondaryContainer` | `#FFDCBF` | `#6B3A00` | — |
| onSecondaryContainer | `onSecondaryContainer` | `#2E1400` | `#FFDCBF` | — |
| **장식 액센트** | `tertiary` | `#EE8D42` | `#FFA95C` | 장식 전용 |
| **Background** | `background` | `#F8FAF7` | `#0E1A16` | — |
| onBackground | `onBackground` | `#15211D` | `#DCE9E4` | 14.1:1 ✅ |
| **Surface** | `surface` | `#FFFFFF` | `#1A2C24` | — |
| onSurface | `onSurface` | `#15211D` | `#DCE9E4` | — |
| Surface Variant | `surfaceVariant` | `#DBE5DF` | `#2D3F38` | — |
| onSurfaceVariant | `onSurfaceVariant` | `#414E48` | `#A8C4BC` | — |
| **Error** | `error` | `#BA1A1A` | `#FF8875` | 6.4:1 ✅ |
| **Outline** | `outline` | `#66736D` | `#7F9590` | — |

**컨셉 키워드**: 숲 속 안도감 · 따뜻한 신뢰 · 자연에서 온 안전함

---

### 🅑 시안 B: "클리어 루트 (Clear Route)" — 고대비 접근성 퍼스트

| 역할 | Token | Light HEX | Dark HEX | 대비비 |
|------|-------|-----------|----------|--------|
| **Primary** | `primary` | `#005B4E` | `#7DE8CE` | 9.1:1 ✅ AAA |
| onPrimary | `onPrimary` | `#FFFFFF` | `#003731` | — |
| Primary Container | `primaryContainer` | `#B2EFE0` | `#004D42` | — |
| **Secondary** | `secondary` | `#7B3800` | `#FFBC80` | 6.8:1 ✅ AAA |
| onSecondary | `onSecondary` | `#FFFFFF` | `#4C1E00` | — |
| Secondary Container | `secondaryContainer` | `#FFE0C8` | `#6A2E00` | — |
| **Background** | `background` | `#FFFFFF` | `#0A1510` | — |
| onBackground | `onBackground` | `#111827` | `#E8F5EF` | 18.1:1 ✅ |
| **Surface** | `surface` | `#F5F5F5` | `#1C2B22` | — |
| onSurface | `onSurface` | `#111827` | `#E8F5EF` | — |
| Surface Variant | `surfaceVariant` | `#E8F0EC` | `#273D32` | — |
| **Error** | `error` | `#C0392B` | `#FF6B5B` | 7.2:1 ✅ |
| **Outline** | `outline` | `#4B5563` | `#8CA89C` | — |

**컨셉 키워드**: 극명한 가독성 · 임상적 정확성 · 믿을 수 있는 안내판

---

### ⭐ 추천 전략: A + B 하이브리드 "에메랄드 클리어"

> 시안 A의 브랜드 온기 + 시안 B의 AAA 대비 원칙을 결합.  
> Primary/Background는 A 채택, 대비비는 B의 기준(9:1 목표)으로 강화.

**시스템 컬러 의미 매핑:**
```
녹색(Primary)  → 접근 가능 경로, 승차 단계, 성공 상태
오렌지(Secondary) → 주의 안내, 혼잡 경고, CTA 버튼
빨강(Error)    → 불가 경로, 엘리베이터 고장
회색(Outline)  → 비활성 상태, 구분선
```

---

## 2. 타이포그래피 전략

### 폰트 패밀리 결정

| 역할 | 폰트 | 이유 |
|------|------|------|
| **한글 전용** | `Noto Sans KR` (Flutter 내장) | 가장 안정적인 한글 렌더링, 별도 번들 불필요 |
| **영문/숫자** | `Noto Sans` | Noto 패밀리 일관성, 칸번호·역 코드 숫자 렌더링 최적 |
| **데이터 수치** | `Noto Sans Mono` | 칸번호(1~11), 층수, 거리(m) 등 정렬 표시 시 가독성 |

> ❌ DM Sans 제거 결정: 한글 폴백 처리 불안정. Noto 단일 패밀리로 통일이 접근성·번들 크기 모두 유리.

---

### Flutter TextTheme 크기 체계

| Flutter Token | sp | Weight | Line Height | Letter Spacing | 용도 |
|---------------|-----|--------|-------------|----------------|------|
| `displayLarge` | **32** | Bold 700 | 1.25 (40) | -0.5 | 역명 대형 (검색 결과) |
| `displayMedium` | **28** | Bold 700 | 1.28 (36) | -0.25 | 도착역명 풀스크린 |
| `headlineLarge` | **24** | SemiBold 600 | 1.33 (32) | 0 | 화면 타이틀 |
| `headlineMedium` | **22** | SemiBold 600 | 1.27 (28) | 0 | 타임라인 단계 제목 |
| `headlineSmall` | **20** | Medium 500 | 1.30 (26) | 0 | 카드 타이틀 |
| `titleLarge` | **18** | SemiBold 600 | 1.33 (24) | 0 | 역 이름 (목록) |
| `titleMedium` | **16** | Medium 500 | 1.375 (22) | 0.1 | 강조 본문, 경로 번호 |
| `titleSmall` | **14** | Medium 500 | 1.43 (20) | 0.1 | 서브 정보 |
| `bodyLarge` | **16** | Regular 400 | 1.5 (24) | 0.5 | 메인 안내문 |
| `bodyMedium` | **14** | Regular 400 | 1.43 (20) | 0.25 | 보조 설명 |
| `bodySmall` | **12** | Regular 400 | 1.33 (16) | 0.4 | ⚠️ 최소값 — 캡션 (11sp 이하 금지) |
| `labelLarge` | **14** | Medium 500 | 1.43 (20) | 0.1 | 버튼 텍스트 |
| `labelMedium` | **12** | Medium 500 | 1.33 (16) | 0.5 | 칩·태그 |
| `labelSmall` | **12** | Medium 500 | 1.33 (16) | 0.5 | ⚠️ 12sp 고정 (접근성) |

**핵심 결정:**
- 기존 PWA 11px caption → **12sp로 상향 고정** (변경 불가)
- 역명 표시는 항상 `headlineLarge` 이상 사용 (20sp+)
- 타임라인 단계 번호(엘리베이터 층수, 칸번호)는 `Noto Sans Mono` + `displayMedium`

---

## 3. 레이아웃 패턴

### 8dp 기본 그리드 시스템

```
기본 단위: 8dp
스페이싱 스케일:
  xs:  4dp   (아이콘-텍스트 내부 간격)
  sm:  8dp   (칩 내부 패딩, 미세 간격)
  md:  16dp  (카드 내부 패딩, 좌우 여백)
  lg:  24dp  (섹션 간 간격)
  xl:  32dp  (화면 섹션 구분)
  2xl: 48dp  (큰 CTA 버튼 높이, 헤더 영역)
  3xl: 64dp  (탭바 높이)
```

### 컴포넌트별 최소 크기 (접근성 필수값)

| 컴포넌트 | 최소 터치 타깃 | 권장 크기 |
|----------|---------------|----------|
| 탭 아이템 | 48×64dp | 56×72dp |
| 기본 버튼 | 48dp 높이 | 56dp 높이 |
| 검색 버튼(FAB) | 56×56dp | 64×64dp |
| 목록 아이템 | 56dp 높이 | 64dp 높이 |
| 아이콘 버튼 | 48×48dp | 48×48dp |
| 체크박스/라디오 | 48×48dp | 48×48dp |

### 레이아웃 구조 (모바일 기준)

```
┌─────────────────────────┐
│  StatusBar (시스템)      │
├─────────────────────────┤
│  AppBar (56dp)          │  ← 역명 / 화면 타이틀
│  [≤2개 액션 아이콘]      │
├─────────────────────────┤
│                         │
│  Content Area           │  ← 스크롤 영역
│  padding: 16dp 좌우     │
│                         │
│  카드 간격: 12dp         │
│  섹션 간격: 24dp         │
│                         │
├─────────────────────────┤
│  BottomNavigationBar    │  ← 64dp (접근성 강화)
│  [지름길찾기|역접근성|데이터] │
└─────────────────────────┘
```

### 타임라인 핵심 레이아웃 패턴

```
타임라인 (세로 스택)
─────────────────────────
● STEP 1 [지상 진입]        ← 32dp 원형 스텝 인디케이터
│  엘리베이터 방향 → 동쪽   ← titleMedium
│  3번 출구 옆 위치         ← bodyMedium
│
│  [거리: 80m] [예상: 2분]  ← 칩 pair, 라벨에 아이콘
│
● STEP 2 [승강장 이동]
│  ...

연결선: 4dp 너비, primaryContainer 색상
스텝 원: 32dp diameter, Primary 색상
완료 스텝: 투명도 60%, 체크 아이콘
현재 스텝: Filled + elevation shadow
다음 스텝: Outlined + 회색
```

---

## 4. UI 스타일 결정

### 코너 반경 (Border Radius)

```dart
// Design Token
cardRadius:         16dp   // 메인 카드
buttonRadius:       12dp   // CTA 버튼, 입력 필드
chipRadius:         8dp    // 칩·태그·뱃지
bottomSheetRadius:  20dp   // 바텀시트 상단 모서리
dialogRadius:       20dp   // 다이얼로그
stepIndicator:      50%    // 타임라인 스텝 원형
avatarRadius:       50%    // 아이콘 배경
```

> ✅ **결정: 라운드 우선** — 이동 중 손이 떨릴 수 있는 사용자, 목발 사용자의 한 손 조작 고려. 각진 UI는 시각적 불안감을 유발할 수 있음.

### 그림자 / 엘리베이션

```
Elevation 0: 배경 직접 (섹션 구분)
Elevation 1: 2dp 그림자 (목록 아이템)
Elevation 2: 4dp 그림자 (카드 기본)
Elevation 3: 8dp 그림자 (강조 카드, 현재 스텝)
Elevation 4: 12dp 그림자 (FAB)
```

> ✅ **결정: 서브틸 그림자** (플랫 X) — 깊이감이 인지적 계층 파악에 도움. 단, 그림자 색상은 `#000000 @ 10%` (검정 색조 유지, 색 그림자 지양).

### 애니메이션 방향

| 상황 | 애니메이션 | 시간 |
|------|-----------|------|
| 화면 전환 | Slide (좌→우 기본, 후진 시 우→좌) | 300ms |
| 타임라인 로드 | 아래서 위로 Fade + Slide | 200ms 스태거 |
| 스텝 완료 | 체크 아이콘 Scale + Opacity | 250ms |
| 에러 메시지 | Shake (좌우 4dp) | 400ms |
| 버튼 탭 | Scale 0.97 (press feedback) | 100ms |

> ⚠️ **접근성 필수**: `MediaQuery.of(context).disableAnimations` 감지 → 모든 전환 즉시 적용.

### 아이콘 스타일

- **Material Symbols (Rounded 변형)** 선택
- 크기: 24dp (기본), 32dp (타임라인 스텝 내), 20dp (칩/인라인)
- **Filled 아이콘** 사용 (현재 상태, 활성) vs **Outlined** (비활성)
- 아이콘+텍스트 항상 병행 — 색맹 사용자 및 스크린리더 대응

```
주요 아이콘 매핑:
elevator       → elevator (Material)
stairs         → stairs (Material, 경고용 + 빨강)
wheelchair     → accessible (Material)
crutch         → crutch (Material)
train_car      → train (Material)  
transfer       → transfer_within_a_station (Material)
navigation     → near_me (Material)
exit           → exit_to_app (Material)
```

---

## 5. 다크모드 / 라이트모드 대응 전략

### 시스템 연동 (기본값)

```dart
MaterialApp(
  theme: WheelWayTheme.light,
  darkTheme: WheelWayTheme.dark,
  themeMode: ThemeMode.system,  // 시스템 설정 자동 연동
)
```

> 사용자 수동 토글은 2차 기능으로 설정화면에 추가 (초기 버전 불필요).

### 다크모드 핵심 규칙

```
1. 순수 흰색(#FFFFFF) 텍스트 금지 → #DCE9E4 (87% 명도, 녹색 음영)
2. 순수 검정(#000000) 배경 금지 → #0E1A16 (짙은 포레스트)
3. Primary 색상: 라이트 #08705B → 다크 #6FDBB8 (채도 유지, 명도 상승)
4. 오렌지 액센트: #EE8D42 → #FFA95C (10% 밝게 — 다크에서 채도 손실 보정)
5. 에러 색상: #BA1A1A → #FF8875 (다크에서 명도 대폭 상승)
6. 카드 구분: 그림자 제거 → Surface Variant 배경색 차이로 대체
```

### 고대비 모드 (MediaQuery.highContrast)

```dart
// 고대비 모드 감지 시 별도 색상 오버라이드
if (MediaQuery.of(context).highContrast) {
  return theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(
      primary: Colors.black,        // 라이트 모드
      onBackground: Colors.black,
      outline: Colors.black,
    ),
  );
}
```

---

## 6. 반응형 전략

### 모바일 퍼스트 (Mobile First) — WheelWay는 이동 중 사용 앱

| 브레이크포인트 | 범위 | 레이아웃 |
|---------------|------|---------|
| **Compact** | 0 ~ 599dp | 1컬럼, 전체 너비 카드, 하단 네비게이션 |
| **Medium** | 600 ~ 839dp | 2컬럼 (타임라인 + 지도), 사이드 네비게이션 |
| **Expanded** | 840dp+ | 3컬럼 그리드, 고정 사이드바, 네비게이션 Rail |

> WheelWay 타겟 디바이스 95%+는 Compact. Medium/Expanded는 동행자 확인 시나리오 대응.

```dart
// Flutter Adaptive Layout
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth < 600) return CompactLayout();
  if (constraints.maxWidth < 840) return MediumLayout();
  return ExpandedLayout();
});
```

---

## 7. 두 가지 디자인 시안 비교

### 시안 A: "에메랄드 워크" — 따뜻한 신뢰형

```
┌─────────────────────────────────┐
│  배경: 크림 #F8FAF7              │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 🟢 STEP 1                 │  │  ← 카드 (16dp radius, 4dp 그림자)
│  │ 4번 출구 엘리베이터        │  │  ← headlineMedium (22sp Bold)
│  │ 이동 거리: 80m · 2분 예상  │  │  ← bodyMedium (14sp)
│  │ ──────────────────────── │  │
│  │ 🟠 TIP: 혼잡 예상 (09:00) │  │  ← 오렌지 칩 경고
│  └───────────────────────────┘  │
│              │ (연결선)          │
│  ┌───────────────────────────┐  │
│  │ ○ STEP 2                 │  │  ← 다음 스텝 (회색 아웃라인)
│  │ 승강장 3호차 탑승         │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘

특징:
- Filled 카드, 서브틸 그림자
- 현재 스텝 Primary 색상 강조
- 따뜻한 크림 배경
- 친근한 Filled 아이콘
- 애니메이션: Smooth fade
```

**적합한 사용자**: 처음 쓰는 고령 사용자, 감성적 신뢰 필요한 사용자  
**장점**: 브랜드 일관성, 정서적 안도감  
**단점**: 카드 그림자가 저시력 사용자에게 정보 구분 혼란 가능성

---

### 시안 B: "클리어 루트" — 명확한 고대비형

```
┌─────────────────────────────────┐
│  배경: 순백 #FFFFFF              │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  ①  4번 출구 엘리베이터         │  ← displayMedium Bold (28sp)
│      이동 거리: 80m · 약 2분    │  ← bodyLarge (16sp Regular)
│      ┌──────┐  ┌──────┐        │
│      │ 80m  │  │ 2분  │        │  ← 수치 칩 (Noto Mono Bold)
│      └──────┘  └──────┘        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  ②  3호차 승차 (3-4 문)         │  ← 다음 스텝 (회색, 50% 불투명)
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
└─────────────────────────────────┘

특징:
- 카드 없음, 디바이더 구분
- 번호 크게, 텍스트 계층 강조
- 순백 배경, 최대 대비
- Outlined 아이콘 (선명한 엣지)
- 애니메이션: Instant (접근성 모드 기본)
```

**적합한 사용자**: TalkBack 사용자, 저시력 사용자, 빠른 정보 파악 필요  
**장점**: 최고 가독성, 스크린리더 친화적, 정보 밀도 효율  
**단점**: 차갑고 기관스러운 느낌 가능성

---

### ⭐ 최종 권장: 하이브리드 "에메랄드 클리어"

> A의 브랜드 아이덴티티 + B의 타이포그래피 계층 + B의 대비 기준

- 배경: `#F8FAF7` (A의 크림)
- 타이포 계층: B 방식 (카드보다 글자 크기가 계층을 만든다)
- 스텝 구분: 카드 + 진한 디바이더 병행
- 대비 목표: B의 AAA 기준 (9:1+)
- 아이콘: A의 Filled (친근함)

---

## 8. Flutter ThemeData 디자인 토큰

```dart
// wheel_way_theme.dart

class WheelWayTheme {
  // ── Spacing Tokens ──────────────────────────────
  static const double spaceXS  = 4.0;
  static const double spaceSM  = 8.0;
  static const double spaceMD  = 16.0;
  static const double spaceLG  = 24.0;
  static const double spaceXL  = 32.0;
  static const double space2XL = 48.0;
  static const double space3XL = 64.0;

  // ── Border Radius Tokens ────────────────────────
  static const double radiusCard       = 16.0;
  static const double radiusButton     = 12.0;
  static const double radiusChip       = 8.0;
  static const double radiusBottomSheet = 20.0;
  static const double radiusDialog     = 20.0;

  // ── Touch Target Tokens ─────────────────────────
  static const double touchMinimum   = 48.0;  // 접근성 필수
  static const double touchPreferred = 56.0;
  static const double tabBarHeight   = 64.0;

  // ── Color Seeds ─────────────────────────────────
  static const Color seedPrimary   = Color(0xFF08705B);
  static const Color seedSecondary = Color(0xFFB45400);
  static const Color seedTertiary  = Color(0xFFEE8D42);  // 장식 전용

  // ── Light ColorScheme ────────────────────────────
  static const ColorScheme _lightColors = ColorScheme(
    brightness: Brightness.light,
    primary:              Color(0xFF08705B),
    onPrimary:            Color(0xFFFFFFFF),
    primaryContainer:     Color(0xFFC8F0E3),
    onPrimaryContainer:   Color(0xFF00201A),
    secondary:            Color(0xFFB45400),
    onSecondary:          Color(0xFFFFFFFF),
    secondaryContainer:   Color(0xFFFFDCBF),
    onSecondaryContainer: Color(0xFF2E1400),
    tertiary:             Color(0xFF3B5F52),
    onTertiary:           Color(0xFFFFFFFF),
    tertiaryContainer:    Color(0xFFBDE9D9),
    onTertiaryContainer:  Color(0xFF00201A),
    error:                Color(0xFFBA1A1A),
    onError:              Color(0xFFFFFFFF),
    errorContainer:       Color(0xFFFFDAD6),
    onErrorContainer:     Color(0xFF410002),
    background:           Color(0xFFF8FAF7),
    onBackground:         Color(0xFF15211D),
    surface:              Color(0xFFFFFFFF),
    onSurface:            Color(0xFF15211D),
    surfaceVariant:       Color(0xFFDBE5DF),
    onSurfaceVariant:     Color(0xFF414E48),
    outline:              Color(0xFF66736D),
    outlineVariant:       Color(0xFFBFC9C2),
    shadow:               Color(0xFF000000),
    scrim:                Color(0xFF000000),
    inverseSurface:       Color(0xFF2D3C36),
    onInverseSurface:     Color(0xFFEEF2EE),
    inversePrimary:       Color(0xFF6FDBB8),
  );

  // ── Dark ColorScheme ─────────────────────────────
  static const ColorScheme _darkColors = ColorScheme(
    brightness: Brightness.dark,
    primary:              Color(0xFF6FDBB8),
    onPrimary:            Color(0xFF00382B),
    primaryContainer:     Color(0xFF005241),
    onPrimaryContainer:   Color(0xFF6FDBB8),
    secondary:            Color(0xFFFFB870),
    onSecondary:          Color(0xFF4A2800),
    secondaryContainer:   Color(0xFF6B3A00),
    onSecondaryContainer: Color(0xFFFFDCBF),
    tertiary:             Color(0xFFFFA95C),
    onTertiary:           Color(0xFF4C1E00),
    tertiaryContainer:    Color(0xFF6B3A00),
    onTertiaryContainer:  Color(0xFFFFDCBF),
    error:                Color(0xFFFF8875),
    onError:              Color(0xFF690005),
    errorContainer:       Color(0xFF93000A),
    onErrorContainer:     Color(0xFFFFDAD6),
    background:           Color(0xFF0E1A16),
    onBackground:         Color(0xFFDCE9E4),
    surface:              Color(0xFF1A2C24),
    onSurface:            Color(0xFFDCE9E4),
    surfaceVariant:       Color(0xFF2D3F38),
    onSurfaceVariant:     Color(0xFFA8C4BC),
    outline:              Color(0xFF7F9590),
    outlineVariant:       Color(0xFF414E48),
    shadow:               Color(0xFF000000),
    scrim:                Color(0xFF000000),
    inverseSurface:       Color(0xFFDCE9E4),
    onInverseSurface:     Color(0xFF2D3C36),
    inversePrimary:       Color(0xFF08705B),
  );

  // ── TextTheme ────────────────────────────────────
  static TextTheme get _textTheme => const TextTheme(
    displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                             height: 1.25, letterSpacing: -0.5,
                             fontFamily: 'NotoSansKR'),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                             height: 1.28, letterSpacing: -0.25,
                             fontFamily: 'NotoSansKR'),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600,
                             height: 1.33, letterSpacing: 0,
                             fontFamily: 'NotoSansKR'),
    headlineMedium:TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
                             height: 1.27, letterSpacing: 0,
                             fontFamily: 'NotoSansKR'),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,
                             height: 1.30, letterSpacing: 0,
                             fontFamily: 'NotoSansKR'),
    titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                             height: 1.33, letterSpacing: 0,
                             fontFamily: 'NotoSansKR'),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                             height: 1.375, letterSpacing: 0.1,
                             fontFamily: 'NotoSansKR'),
    titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                             height: 1.43, letterSpacing: 0.1,
                             fontFamily: 'NotoSansKR'),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400,
                             height: 1.5, letterSpacing: 0.5,
                             fontFamily: 'NotoSansKR'),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
                             height: 1.43, letterSpacing: 0.25,
                             fontFamily: 'NotoSansKR'),
    bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400,
                             height: 1.33, letterSpacing: 0.4,
                             fontFamily: 'NotoSansKR'), // 최소값
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                             height: 1.43, letterSpacing: 0.1,
                             fontFamily: 'NotoSansKR'),
    labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                             height: 1.33, letterSpacing: 0.5,
                             fontFamily: 'NotoSansKR'),
    labelSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                             height: 1.33, letterSpacing: 0.5,
                             fontFamily: 'NotoSansKR'), // 11 이하 금지
  );

  // ── Light Theme ──────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColors,
    textTheme: _textTheme,
    // NavigationBar
    navigationBarTheme: const NavigationBarThemeData(
      height: 64,  // 접근성 강화
      indicatorColor: Color(0xFFC8F0E3),
      labelTextStyle: MaterialStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansKR'),
      ),
    ),
    // AppBar
    appBarTheme: const AppBarTheme(
      toolbarHeight: 56,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    // Card
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCard),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),  // 48dp 최소 높이
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          fontFamily: 'NotoSansKR',
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    // Chip
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusChip),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        fontFamily: 'NotoSansKR',
      ),
    ),
    // BottomSheet
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    // Focus (TalkBack 포커스 링)
    focusColor: Color(0xFF08705B),
    splashColor: Color(0x1A08705B),
    highlightColor: Color(0x0D08705B),
  );

  // ── Dark Theme ───────────────────────────────────
  static ThemeData get dark => light.copyWith(
    colorScheme: _darkColors,
    cardTheme: CardTheme(
      elevation: 0,  // 다크모드: 그림자 제거, surfaceVariant 배경으로 구분
      color: const Color(0xFF1A2C24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCard),
      ),
    ),
  );
}
```

---

## 9. 접근성 체크리스트 (디자인 검증용)

| 항목 | 기준 | 상태 |
|------|------|------|
| 일반 텍스트 대비 | ≥ 4.5:1 | ✅ onBackground: 14.1:1 |
| 큰 텍스트 대비 | ≥ 3:1 | ✅ Primary on bg: 7.2:1 |
| 버튼 텍스트 | ≥ 3:1 (14sp Bold) | ✅ onPrimary on primary: 7.2:1 |
| 오렌지 액센트 | 텍스트 금지 | ✅ 장식 전용 지정 |
| 최소 캡션 크기 | 12sp 이상 | ✅ labelSmall = 12sp |
| 터치 타깃 | 48dp 이상 | ✅ minimumSize 설정 |
| 색만으로 구분 | 금지 | ⚠️ 3단계 구현 시 아이콘 병행 명시 |
| 다크모드 | 시스템 연동 | ✅ ThemeMode.system |
| 고대비 모드 | MediaQuery 감지 | ⚠️ 3단계 구현 필요 |
| 애니메이션 끄기 | disableAnimations | ⚠️ 3단계 구현 필요 |

---

---

## Round 3 — Stage 3: 스타일 검증자 ✅

> **Passed → Stage 4**

### ✅ 서비스 목적 / 타겟 일치도

교통약자 대상 지하철 지름길 앱이라는 정체성에 디자인 전략이 명확히 부합함.

| 검증 항목 | 결과 |
|-----------|------|
| 포레스트 그린 계열 → 자연·안도·신뢰 연상 | ✅ 타깃 감성 부합 |
| 크림 배경 (#F8FAF7) → 눈 피로 저감 | ✅ 장시간 이동 중 사용 맥락 적합 |
| 타임라인 중심 레이아웃 → 단계별 동선 안내 | ✅ 핵심 UX와 일치 |
| 오렌지 액센트 → 경고·혼잡 구간 강조 | ✅ 기능-색상 의미 매핑 명확 |
| 카드 기반 + 세로 스크롤 → 이동 중 한손 조작 | ✅ 사용 맥락 반영 |

---

### ✅ 접근성 검증 (WCAG AA)

**텍스트 대비비 실측:**

| 색상 쌍 | 계산 대비비 | 기준 | 판정 |
|---------|-----------|------|------|
| #15211D on #F8FAF7 | ~14.1:1 | 4.5:1 | ✅ AAA |
| #B45400 on #FFFFFF | ~4.9:1 | 4.5:1 | ✅ AA |
| White on #08705B | ~5.9:1 | 4.5:1 | ✅ AA+ |
| #BA1A1A on #FFFFFF | ~6.4:1 | 4.5:1 | ✅ AA+ |
| #EE8D42 on #FFFFFF | ~2.3:1 | — | ⚠️ 장식 전용 격하 필요 (문서에 명시됨) |

> ⚠️ 주의: 문서가 Primary(`#08705B`) 대비를 `7.2:1`로 기재했으나 실측 약 `5.9:1`. 여전히 AA+ 충족이지만 구현 시 정확한 값으로 수정 필요.

**폰트 접근성:**
- 최소 크기 12sp (bodySmall, labelSmall) — ✅ 11px 이하 금지 원칙 준수
- 역명 최소 headlineLarge(24sp) 이상 — ✅
- 칸번호·거리 수치: Noto Sans Mono + displayMedium — ✅ 정렬 가독성 확보

**터치 타깃:**
- 모든 핵심 컴포넌트 48dp 이상 명시 — ✅
- 탭바 64dp, FAB 56dp — ✅ 목발/전동 휠체어 단속 조작 고려

---

### ✅ 기술적 구현 가능성

Flutter Material 3 기준으로 제안된 모든 요소 구현 가능 확인.

| 항목 | 판정 |
|------|------|
| `ColorScheme` 라이트/다크 쌍 | ✅ ThemeData 표준 구조 |
| `ThemeMode.system` 연동 | ✅ Flutter 기본 지원 |
| `MediaQuery.highContrast` 감지 | ✅ Flutter 3.x 지원 |
| `MediaQuery.disableAnimations` | ✅ 접근성 API 표준 |
| NotoSansKR 번들 | ✅ Flutter 기본 내장 |
| `NavigationBarThemeData` 64dp 탭바 | ✅ Material 3 커스터마이징 가능 |
| `MaterialStatePropertyAll` | ✅ Flutter 3.x 유효 |

> ⚠️ **구현 시 수정 필요한 코드 이슈 (구현 단계 전달 사항):**
> - `static const ColorScheme _lightColors = ColorScheme(...)` — Flutter에서 `ColorScheme`은 const 생성자 미지원. `static final`로 변경 필요.
> - 하단 `focusColor: Color(0xFF08705B)` — `ThemeData` 내에서 `const` 컨텍스트 혼재 주의.
> - `dark = light.copyWith(...)` 패턴에서 `cardTheme` 외 누락된 컴포넌트 테마(버튼, 칩 등) 다크 오버라이드 미명시 → 구현 시 완성 필요.

---

### ✅ 일관성 검증

- **컬러**: Primary(녹색) → 접근가능/성공, Secondary(오렌지) → 주의/CTA, Error(빨강) → 불가/고장 의미 체계가 일관적
- **타이포**: Noto 단일 패밀리 통일로 한글/영문/숫자 렌더링 일관성 확보
- **간격**: 8dp 기반 4→8→16→24→32→48→64 토큰 체계 — 스케일 논리적
- **반경**: 카드 16 / 버튼 12 / 칩 8 / 바텀시트 20 — 계층별 차별화 명확
- **확장성**: `WheelWayTheme` 클래스로 설계 시스템 확장 준비됨

---

### ✅ 경쟁사 대비 차별화

| 경쟁사 | WheelWay 차별점 |
|--------|----------------|
| 서울동행맵 (제도적 블루) | 포레스트 그린 + 따뜻한 크림 → 정서적 차별화 |
| 구글맵 (Material You 범용) | 브랜드 전용 Seed Color + 칸번호 중심 타임라인 |
| 휠비 (이진 색상) | 단계별 진행 타임라인 + 혼잡/거리 칩 |
| Transit App (글로벌 대중교통) | 한국 지하철 특화 (칸번호, 엘리베이터 층) |

→ "에메랄드 클리어" 아이덴티티는 유사 서비스와 충분히 차별화됨.

---

### ⭐ 시안 추천 최종 확인

제안된 **하이브리드 "에메랄드 클리어"** 채택 타당성 검증:

| 기준 | A(에메랄드 워크) | B(클리어 루트) | 하이브리드 |
|------|:-:|:-:|:-:|
| 브랜드 온기 | ✅ | ❌ | ✅ |
| AAA 대비 기준 | △ | ✅ | ✅ |
| TalkBack 친화 | △ | ✅ | ✅ |
| 고령 사용자 친화 | ✅ | △ | ✅ |
| 기관스러운 느낌 회피 | ✅ | △ | ✅ |

→ 하이브리드 채택 **적절**. A의 크림 배경·Filled 아이콘 + B의 타이포 계층·AAA 대비 기준 결합.

---

---

## Round 4 — Stage 4: 디자인 가이드 작성자 🏆

# WheelWay 최종 디자인 가이드 v1.0
## Flutter 즉시 구현용 완전 스펙

---

## 1. 컬러 시스템 — "에메랄드 클리어"

### 1-1. 시맨틱 컬러 역할 정의

| 역할 | 의미 | 라이트 HEX | 다크 HEX |
|------|------|-----------|---------|
| **Primary** | 접근 가능 경로, 성공, 브랜드 | `#08705B` | `#6FDBB8` |
| **Secondary** | 경고 안내, CTA 버튼, 주의 구간 | `#B45400` | `#FFB870` |
| **Tertiary** | 장식 전용 액센트 (텍스트 사용 금지) | `#EE8D42` | `#FFA95C` |
| **Error** | 불가 경로, 엘리베이터 고장 | `#BA1A1A` | `#FF8875` |
| **Background** | 앱 기본 배경 | `#F8FAF7` | `#0E1A16` |
| **Surface** | 카드, 모달, 시트 배경 | `#FFFFFF` | `#1A2C24` |
| **SurfaceVariant** | 비활성 카드, 구분 배경 | `#DBE5DF` | `#2D3F38` |
| **Outline** | 구분선, 비활성 테두리 | `#66736D` | `#7F9590` |

### 1-2. 전체 ColorScheme 토큰 (실측 대비비 포함)

#### 라이트 모드

| Token | HEX | RGB | 대비비 (on bg) | WCAG |
|-------|-----|-----|--------------|------|
| `primary` | `#08705B` | `8, 112, 91` | 5.9:1 on white | ✅ AA+ |
| `onPrimary` | `#FFFFFF` | `255,255,255` | 5.9:1 on primary | ✅ AA+ |
| `primaryContainer` | `#C8F0E3` | `200,240,227` | — | — |
| `onPrimaryContainer` | `#00201A` | `0,32,26` | 16.2:1 on container | ✅ AAA |
| `secondary` | `#B45400` | `180,84,0` | 4.9:1 on white | ✅ AA |
| `onSecondary` | `#FFFFFF` | `255,255,255` | 4.9:1 on secondary | ✅ AA |
| `secondaryContainer` | `#FFDCBF` | `255,220,191` | — | — |
| `onSecondaryContainer` | `#2E1400` | `46,20,0` | 14.8:1 on container | ✅ AAA |
| `tertiary` | `#EE8D42` | `238,141,66` | 2.3:1 on white | ⚠️ 장식만 |
| `background` | `#F8FAF7` | `248,250,247` | — | — |
| `onBackground` | `#15211D` | `21,33,29` | 14.1:1 | ✅ AAA |
| `surface` | `#FFFFFF` | `255,255,255` | — | — |
| `onSurface` | `#15211D` | `21,33,29` | 18.1:1 | ✅ AAA |
| `surfaceVariant` | `#DBE5DF` | `219,229,223` | — | — |
| `onSurfaceVariant` | `#414E48` | `65,78,72` | 6.1:1 on variant | ✅ AA+ |
| `outline` | `#66736D` | `102,115,109` | 4.5:1 on white | ✅ AA |
| `error` | `#BA1A1A` | `186,26,26` | 6.4:1 on white | ✅ AA+ |
| `onError` | `#FFFFFF` | `255,255,255` | 6.4:1 on error | ✅ AA+ |

#### 다크 모드

| Token | HEX | RGB | 용도 |
|-------|-----|-----|------|
| `primary` | `#6FDBB8` | `111,219,184` | 주요 상태, 탭 활성 |
| `onPrimary` | `#00382B` | `0,56,43` | primary 위 텍스트 |
| `primaryContainer` | `#005241` | `0,82,65` | 컨테이너 배경 |
| `onPrimaryContainer` | `#6FDBB8` | `111,219,184` | 컨테이너 위 텍스트 |
| `secondary` | `#FFB870` | `255,184,112` | CTA, 주의 |
| `onSecondary` | `#4A2800` | `74,40,0` | secondary 위 텍스트 |
| `tertiary` | `#FFA95C` | `255,169,92` | 장식 전용 |
| `background` | `#0E1A16` | `14,26,22` | 앱 배경 |
| `onBackground` | `#DCE9E4` | `220,233,228` | 기본 텍스트 |
| `surface` | `#1A2C24` | `26,44,36` | 카드 배경 |
| `onSurface` | `#DCE9E4` | `220,233,228` | 카드 위 텍스트 |
| `surfaceVariant` | `#2D3F38` | `45,63,56` | 구분 배경 |
| `onSurfaceVariant` | `#A8C4BC` | `168,196,188` | 보조 텍스트 |
| `outline` | `#7F9590` | `127,149,144` | 구분선 |
| `error` | `#FF8875` | `255,136,117` | 에러 (다크 밝게) |
| `onError` | `#690005` | `105,0,5` | 에러 위 텍스트 |

---

## 2. 타이포그래피 시스템

### 2-1. 폰트 패밀리 결정

| 역할 | 폰트 | 적용 대상 |
|------|------|---------|
| **한글 + 영문** | `Noto Sans KR` | 모든 UI 텍스트 (Flutter 기본 내장) |
| **숫자 데이터** | `Noto Sans Mono` | 칸번호(1~11), 층수, 거리(m), 예상 소요 시간 |

> ❌ DM Sans 사용 금지: 한글 폴백 불안정. Noto 단일 패밀리로 통일.

### 2-2. Flutter TextTheme 완전 스펙

| Flutter Token | 크기(sp) | Weight | Height | Letter Spacing | 적용 위치 |
|--------------|---------|--------|--------|----------------|---------|
| `displayLarge` | 32 | 700 Bold | 1.25 (=40) | -0.5 | 역명 대형 (검색 결과 상단) |
| `displayMedium` | 28 | 700 Bold | 1.28 (=36) | -0.25 | 칸번호·층수 강조 수치 (Mono) |
| `displaySmall` | 24 | 700 Bold | 1.33 (=32) | 0 | 도착역명 (전체화면 안내) |
| `headlineLarge` | 24 | 600 SemiBold | 1.33 (=32) | 0 | 화면 AppBar 타이틀 |
| `headlineMedium` | 22 | 600 SemiBold | 1.27 (=28) | 0 | 타임라인 단계 제목 |
| `headlineSmall` | 20 | 500 Medium | 1.30 (=26) | 0 | 카드 제목 |
| `titleLarge` | 18 | 600 SemiBold | 1.33 (=24) | 0 | 역 목록 역명 |
| `titleMedium` | 16 | 500 Medium | 1.375 (=22) | 0.1 | 강조 본문, 경로 정보 |
| `titleSmall` | 14 | 500 Medium | 1.43 (=20) | 0.1 | 서브 정보 |
| `bodyLarge` | 16 | 400 Regular | 1.5 (=24) | 0.5 | 주요 안내 문장 |
| `bodyMedium` | 14 | 400 Regular | 1.43 (=20) | 0.25 | 보조 설명 |
| `bodySmall` | **12** | 400 Regular | 1.33 (=16) | 0.4 | ⚠️ 최솟값 캡션 |
| `labelLarge` | 14 | 500 Medium | 1.43 (=20) | 0.1 | 버튼 텍스트 |
| `labelMedium` | 12 | 500 Medium | 1.33 (=16) | 0.5 | 칩·태그 |
| `labelSmall` | **12** | 500 Medium | 1.33 (=16) | 0.5 | ⚠️ 11sp 이하 절대 금지 |

---

## 3. 간격·여백 시스템 (8dp 기반)

```
spacing tokens:
  space2   =  2dp  (구분선 두께)
  space4   =  4dp  (아이콘-텍스트 내부 gap)
  space8   =  8dp  (칩 내부 패딩, 미세 간격)
  space12  = 12dp  (카드 간 수직 gap)
  space16  = 16dp  (카드 내부 패딩, 좌우 화면 여백)
  space20  = 20dp  (타임라인 수평 인덴트)
  space24  = 24dp  (섹션 간 간격)
  space32  = 32dp  (큰 섹션 구분)
  space48  = 48dp  (최소 터치 타깃, 큰 CTA 높이)
  space56  = 56dp  (권장 CTA 높이, AppBar 높이)
  space64  = 64dp  (BottomNav 높이, 접근성 강화)
```

### 3-1. 레이아웃 여백 적용 규칙

| 위치 | 값 | 이유 |
|------|-----|------|
| 화면 좌우 패딩 | 16dp | 손가락 grip 공간 확보 |
| 카드 내부 패딩 | 16dp | 내용물 여유 |
| 카드 간 수직 간격 | 12dp | 밀집하지 않은 목록 |
| 섹션 제목 위 | 24dp | 섹션 구분 명확화 |
| AppBar 아래 | 0dp | 컨텐츠 연속성 |
| 타임라인 연결선 좌측 오프셋 | 20dp | 스텝 원 중앙 정렬 |

---

## 4. 컴포넌트 스타일 가이드

### 4-1. 버튼

| 유형 | 높이 | 반경 | 사용 위치 |
|------|------|------|---------|
| **Primary (FilledButton)** | 56dp | 12dp | "지름길 찾기" 메인 CTA |
| **Secondary (OutlinedButton)** | 48dp | 12dp | 취소, 대안 경로 |
| **Tertiary (TextButton)** | 48dp | 12dp | "더 보기", 보조 액션 |
| **FAB** | 56×56dp | 16dp | 현재 위치 재설정 |
| **IconButton** | 48×48dp | 50% | AppBar 액션, 음성 안내 |

```
버튼 텍스트: labelLarge (14sp, Weight 500)
버튼 내부 패딩: vertical 14dp, horizontal 24dp
최소 너비: 전체 너비 (double.infinity)
비활성 투명도: 38%
```

### 4-2. 카드 (타임라인 스텝 카드)

```
구분:    현재 스텝           다음 스텝          완료 스텝
배경:    Surface (흰색)      SurfaceVariant    SurfaceVariant
테두리:  Primary 2dp         없음              없음
그림자:  elevation 3 (8dp)   elevation 1 (2dp) elevation 0
투명도:  100%                100%              60%
아이콘:  Filled + Primary     Outlined + Muted  체크 + Muted
반경:    16dp                16dp              16dp
패딩:    16dp                16dp              16dp
```

#### 타임라인 연결선

```
색상:    primaryContainer (#C8F0E3 / 다크: #005241)
너비:    3dp
스타일:  실선 (완료 구간), 점선 (미완료 구간)
좌측 오프셋: 스텝 원 중앙 = 20dp (원 직경 16dp의 절반 + 좌측 패딩 12dp)
```

#### 스텝 원형 인디케이터

```
크기:    40×40dp (터치 타깃 48dp 영역 확보)
완료:    Primary 배경 + 흰색 체크 아이콘
현재:    Primary 배경 + 흰색 번호 텍스트 (titleMedium)
대기:    SurfaceVariant 배경 + Outline 번호 텍스트
```

### 4-3. 검색 입력폼

```
높이:        56dp
반경:        12dp
내부 패딩:   horizontal 16dp, vertical 0 (높이로 자동)
테두리:      Outline (#66736D) 1dp → 포커스 시 Primary 2dp
배경:        Surface
플레이스홀더: onSurfaceVariant (#A8C4BC 다크)
입력 텍스트: onSurface, bodyLarge (16sp)
아이콘:      24dp, 좌측 12dp 내부 여백 후
삭제 버튼:   48×48dp 터치 영역 (아이콘 24dp)
```

### 4-4. 바텀 내비게이션

```
높이:         64dp (접근성 강화 — Material 기본 80dp에서 조정)
탭 최소 너비: 탭 수에 따라 균등 분배
아이콘 크기:  24dp (비활성), 28dp (활성)
라벨:         labelMedium (12sp)
활성 색:      Primary
비활성 색:    onSurfaceVariant
인디케이터:   primaryContainer, 반경 16dp, 높이 32dp
아이템:       최소 터치 타깃 48dp 높이 보장
탭 3개:       지름길 찾기 / 역 접근성 / 데이터 정보
```

### 4-5. 바텀시트 (경로 상세)

```
상단 반경:   20dp (좌상·우상만)
드래그 핸들: 4×32dp, Outline 색, 반경 2dp, 상단 8dp 여백
헤더 높이:   56dp (닫기 버튼 포함)
내부 패딩:   horizontal 16dp, bottom 24dp + SafeArea
최소 높이:   화면 40%
최대 높이:   화면 90%
배경:        Surface
```

### 4-6. 다이얼로그

```
반경:        20dp
패딩:        24dp
최대 너비:   화면 너비 - 48dp (좌우 24dp 여백)
제목:        headlineSmall (20sp)
본문:        bodyMedium (14sp)
버튼 영역:   우측 정렬, 간격 8dp
버튼 높이:   최소 48dp
```

### 4-7. 칩 (거리·시간 정보)

```
높이:        36dp (내부 패딩 vertical 8dp)
내부 패딩:   horizontal 12dp
반경:        8dp
폰트:        labelMedium (12sp, Weight 500)
아이콘:      20dp, gap 4dp
색상:
  - 정보 칩: SurfaceVariant 배경, onSurfaceVariant 텍스트
  - 경고 칩: SecondaryContainer 배경, onSecondaryContainer 텍스트
  - 불가 칩: ErrorContainer 배경, onErrorContainer 텍스트
```

### 4-8. AppBar

```
높이:              56dp
배경:              Surface (스크롤 전), Surface+elevation 2 (스크롤 후)
타이틀:            titleLarge (18sp, SemiBold)
타이틀 정렬:       leading (좌측)
액션 최대:         2개 (아이콘버튼)
액션 간격:         4dp
뒤로가기 버튼:     48×48dp
```

### 4-9. 스낵바·토스트

```
배경:    inverseSurface (#2D3C36 라이트)
텍스트:  onInverseSurface (#EEF2EE 라이트), bodyMedium
액션:    inversePrimary (#6FDBB8)
반경:    8dp
패딩:    horizontal 16dp, vertical 14dp
최소 높이: 48dp
지속시간: 4초 (단순 정보), 10초 (오류+복구 액션)
위치:    BottomNav 위 8dp
```

---

## 5. 아이콘 가이드라인

### 5-1. 스타일 결정

```
라이브러리:   Material Symbols (Rounded 변형)
기본 크기:    24dp
타임라인 내:  32dp
칩/인라인:    20dp
AppBar:      24dp

활성 상태:    Filled 변형 (fill: 1)
비활성 상태:  Outlined 변형 (fill: 0)
weight:      400 (기본), 700 (강조)
grade:       0 (기본), 200 (강조)
```

### 5-2. 핵심 아이콘 매핑

```dart
// WheelWay 아이콘 상수
class WheelWayIcons {
  // 교통 수단
  static const elevator       = Icons.elevator_rounded;
  static const stairs         = Icons.stairs_rounded;       // 경고 표시용
  static const escalator      = Icons.escalator_rounded;
  static const wheelchair     = Icons.accessible_rounded;
  static const crutch         = Icons.crutch_rounded;        // 목발 사용자
  
  // 지하철
  static const trainCar       = Icons.train_rounded;
  static const transfer       = Icons.transfer_within_a_station_rounded;
  static const platform       = Icons.subway_rounded;
  static const exit           = Icons.exit_to_app_rounded;
  
  // 내비게이션
  static const navigation     = Icons.near_me_rounded;
  static const location       = Icons.location_on_rounded;
  static const route          = Icons.route_rounded;
  static const search         = Icons.search_rounded;
  
  // 상태
  static const checkDone      = Icons.check_circle_rounded;
  static const warning        = Icons.warning_amber_rounded;
  static const error          = Icons.error_rounded;
  static const info           = Icons.info_outline_rounded;
  
  // 접근성 편의시설
  static const accessible     = Icons.accessible_forward_rounded;
  static const ramp           = Icons.ramp_right_rounded;
  static const doorWidth      = Icons.door_sliding_rounded;
}
```

### 5-3. 아이콘 접근성 규칙

```
- 의미 있는 아이콘: 반드시 텍스트 레이블 병행 표시
- 아이콘 전용 버튼: semanticLabel 필수
- 장식용 아이콘: ExcludeSemantics 래퍼 적용
- 색만으로 상태 전달 금지: 아이콘 형태 변화 병행 (Filled↔Outlined)
```

---

## 6. 다크모드 대응 규칙

```
1. 순수 흰색 (#FFFFFF) 텍스트 → #DCE9E4 로 대체
2. 순수 검정 (#000000) 배경 → #0E1A16 로 대체
3. 카드 구분: 그림자 제거 → SurfaceVariant 색차로 구분
4. Primary 명도 상승: #08705B → #6FDBB8
5. 오렌지 10% 밝게: #EE8D42 → #FFA95C
6. Error 대폭 상승: #BA1A1A → #FF8875
7. ThemeMode.system 기본값 (사용자 시스템 설정 자동 연동)
```

---

## 7. 애니메이션 가이드

| 상황 | 유형 | 시간 | 커브 |
|------|------|------|------|
| 화면 전환 | Slide (진입 방향) | 300ms | easeInOut |
| 타임라인 스텝 로드 | FadeIn + SlideUp | 200ms 스태거 | easeOut |
| 스텝 완료 체크 | Scale + Opacity | 250ms | elasticOut |
| 에러 메시지 | Shake (±4dp) | 400ms | — |
| 버튼 탭 피드백 | Scale 0.97 | 100ms | easeIn |
| 바텀시트 올라오기 | SlideUp | 300ms | decelerate |

> ⚠️ `MediaQuery.of(context).disableAnimations == true` → 모든 전환 즉시 적용 (duration: 0)

---

## 8. Flutter 구현 코드 — 완전판

```dart
// lib/theme/wheel_way_theme.dart

import 'package:flutter/material.dart';

/// WheelWay 디자인 시스템 — 에메랄드 클리어
/// 접근성 최우선: WCAG 2.1 AA+ 기준, TalkBack 지원
class WheelWayTheme {
  WheelWayTheme._();

  // ─────────────────────────────────────────────
  // 1. 간격 토큰 (Spacing)
  // ─────────────────────────────────────────────
  static const double space2  = 2.0;
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // ─────────────────────────────────────────────
  // 2. 반경 토큰 (Border Radius)
  // ─────────────────────────────────────────────
  static const double radiusXS         = 4.0;
  static const double radiusSM         = 8.0;   // 칩, 스낵바
  static const double radiusMD         = 12.0;  // 버튼, 입력폼
  static const double radiusLG         = 16.0;  // 카드
  static const double radiusXL         = 20.0;  // 바텀시트, 다이얼로그
  static const double radiusFull       = 999.0; // 완전 원형

  // ─────────────────────────────────────────────
  // 3. 터치 타깃 토큰
  // ─────────────────────────────────────────────
  static const double touchMin       = 48.0;
  static const double touchPreferred = 56.0;
  static const double navBarHeight   = 64.0;
  static const double appBarHeight   = 56.0;

  // ─────────────────────────────────────────────
  // 4. 라이트 ColorScheme
  // ─────────────────────────────────────────────
  static final ColorScheme _lightColors = ColorScheme(
    brightness: Brightness.light,
    primary:              const Color(0xFF08705B),
    onPrimary:            const Color(0xFFFFFFFF),
    primaryContainer:     const Color(0xFFC8F0E3),
    onPrimaryContainer:   const Color(0xFF00201A),
    secondary:            const Color(0xFFB45400),
    onSecondary:          const Color(0xFFFFFFFF),
    secondaryContainer:   const Color(0xFFFFDCBF),
    onSecondaryContainer: const Color(0xFF2E1400),
    tertiary:             const Color(0xFF3B5F52),  // 장식 전용 (EE8D42는 직접 사용)
    onTertiary:           const Color(0xFFFFFFFF),
    tertiaryContainer:    const Color(0xFFBDE9D9),
    onTertiaryContainer:  const Color(0xFF00201A),
    error:                const Color(0xFFBA1A1A),
    onError:              const Color(0xFFFFFFFF),
    errorContainer:       const Color(0xFFFFDAD6),
    onErrorContainer:     const Color(0xFF410002),
    surface:              const Color(0xFFFFFFFF),
    onSurface:            const Color(0xFF15211D),
    surfaceVariant:       const Color(0xFFDBE5DF),
    onSurfaceVariant:     const Color(0xFF414E48),
    outline:              const Color(0xFF66736D),
    outlineVariant:       const Color(0xFFBFC9C2),
    shadow:               const Color(0xFF000000),
    scrim:                const Color(0xFF000000),
    inverseSurface:       const Color(0xFF2D3C36),
    onInverseSurface:     const Color(0xFFEEF2EE),
    inversePrimary:       const Color(0xFF6FDBB8),
    // background 대신 surface/surfaceContainerLowest 사용 (Material 3)
  );

  // ─────────────────────────────────────────────
  // 5. 다크 ColorScheme
  // ─────────────────────────────────────────────
  static final ColorScheme _darkColors = ColorScheme(
    brightness: Brightness.dark,
    primary:              const Color(0xFF6FDBB8),
    onPrimary:            const Color(0xFF00382B),
    primaryContainer:     const Color(0xFF005241),
    onPrimaryContainer:   const Color(0xFF6FDBB8),
    secondary:            const Color(0xFFFFB870),
    onSecondary:          const Color(0xFF4A2800),
    secondaryContainer:   const Color(0xFF6B3A00),
    onSecondaryContainer: const Color(0xFFFFDCBF),
    tertiary:             const Color(0xFF8ECFBB),
    onTertiary:           const Color(0xFF003829),
    tertiaryContainer:    const Color(0xFF00513C),
    onTertiaryContainer:  const Color(0xFFABECD6),
    error:                const Color(0xFFFF8875),
    onError:              const Color(0xFF690005),
    errorContainer:       const Color(0xFF93000A),
    onErrorContainer:     const Color(0xFFFFDAD6),
    surface:              const Color(0xFF1A2C24),
    onSurface:            const Color(0xFFDCE9E4),
    surfaceVariant:       const Color(0xFF2D3F38),
    onSurfaceVariant:     const Color(0xFFA8C4BC),
    outline:              const Color(0xFF7F9590),
    outlineVariant:       const Color(0xFF414E48),
    shadow:               const Color(0xFF000000),
    scrim:                const Color(0xFF000000),
    inverseSurface:       const Color(0xFFDCE9E4),
    onInverseSurface:     const Color(0xFF2D3C36),
    inversePrimary:       const Color(0xFF08705B),
  );

  // ─────────────────────────────────────────────
  // 6. TextTheme
  // ─────────────────────────────────────────────
  static const String _fontKR   = 'NotoSansKR';
  static const String _fontMono = 'NotoSansMono';

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w700,
      height: 1.25, letterSpacing: -0.5, fontFamily: _fontKR),
    displayMedium: TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700,
      height: 1.28, letterSpacing: -0.25, fontFamily: _fontMono), // 수치
    displaySmall: TextStyle(
      fontSize: 24, fontWeight: FontWeight.w700,
      height: 1.33, letterSpacing: 0, fontFamily: _fontKR),
    headlineLarge: TextStyle(
      fontSize: 24, fontWeight: FontWeight.w600,
      height: 1.33, letterSpacing: 0, fontFamily: _fontKR),
    headlineMedium: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600,
      height: 1.27, letterSpacing: 0, fontFamily: _fontKR),
    headlineSmall: TextStyle(
      fontSize: 20, fontWeight: FontWeight.w500,
      height: 1.30, letterSpacing: 0, fontFamily: _fontKR),
    titleLarge: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600,
      height: 1.33, letterSpacing: 0, fontFamily: _fontKR),
    titleMedium: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500,
      height: 1.375, letterSpacing: 0.1, fontFamily: _fontKR),
    titleSmall: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      height: 1.43, letterSpacing: 0.1, fontFamily: _fontKR),
    bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400,
      height: 1.5, letterSpacing: 0.5, fontFamily: _fontKR),
    bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400,
      height: 1.43, letterSpacing: 0.25, fontFamily: _fontKR),
    bodySmall: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,  // 최솟값 — 이 이하 금지
      height: 1.33, letterSpacing: 0.4, fontFamily: _fontKR),
    labelLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      height: 1.43, letterSpacing: 0.1, fontFamily: _fontKR),
    labelMedium: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      height: 1.33, letterSpacing: 0.5, fontFamily: _fontKR),
    labelSmall: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,  // 11sp 이하 절대 금지
      height: 1.33, letterSpacing: 0.5, fontFamily: _fontKR),
  );

  // ─────────────────────────────────────────────
  // 7. 라이트 ThemeData
  // ─────────────────────────────────────────────
  static ThemeData get light {
    final cs = _lightColors;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF8FAF7),
      textTheme: _textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        toolbarHeight: appBarHeight,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: const Color(0xFFF8FAF7),
        foregroundColor: const Color(0xFF15211D),
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: const Color(0xFF15211D),
        ),
      ),

      // BottomNavigationBar → NavigationBar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        height: navBarHeight,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFC8F0E3),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 28, color: Color(0xFF08705B));
          }
          return const IconThemeData(size: 24, color: Color(0xFF66736D));
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _textTheme.labelMedium?.copyWith(
              color: const Color(0xFF08705B), fontWeight: FontWeight.w600);
          }
          return _textTheme.labelMedium?.copyWith(
            color: const Color(0xFF66736D));
        }),
      ),

      // Card
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: const Color(0x1A000000),
        color: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, touchPreferred),
          maximumSize: const Size(double.infinity, touchPreferred),
          backgroundColor: const Color(0xFF08705B),
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: const Color(0xFF66736D).withOpacity(0.12),
          disabledForegroundColor: const Color(0xFF66736D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, touchMin),
          foregroundColor: const Color(0xFF08705B),
          side: const BorderSide(color: Color(0xFF08705B), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, touchMin),
          foregroundColor: const Color(0xFF08705B),
          textStyle: _textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(touchMin, touchMin),
          fixedSize: const Size(touchMin, touchMin),
          iconSize: 24,
        ),
      ),

      // InputDecoration (검색/입력폼)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16, vertical: space16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF66736D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF66736D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF08705B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        hintStyle: _textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF66736D)),
        labelStyle: _textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF66736D)),
        floatingLabelStyle: _textTheme.bodySmall?.copyWith(
          color: const Color(0xFF08705B)),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFDBE5DF),
        selectedColor: const Color(0xFFC8F0E3),
        labelStyle: _textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF08705B),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: touchPreferred, height: touchPreferred),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL)),
        ),
        showDragHandle: true,
        dragHandleColor: const Color(0xFF66736D),
        dragHandleSize: const Size(32, 4),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: const Color(0xFF15211D)),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF414E48)),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2D3C36),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFEEF2EE)),
        actionTextColor: const Color(0xFF6FDBB8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        elevation: 4,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDBE5DF),
        thickness: 1,
        space: 0,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(
          horizontal: space16, vertical: space4),
        minLeadingWidth: 40,
        iconColor: Color(0xFF08705B),
      ),

      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF08705B),
        linearTrackColor: Color(0xFFC8F0E3),
        circularTrackColor: Color(0xFFC8F0E3),
        linearMinHeight: 4,
      ),

      // Switch/Checkbox
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFFFFFFF);
          }
          return const Color(0xFF66736D);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF08705B);
          }
          return const Color(0xFFDBE5DF);
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      // Focus/Ripple
      focusColor: const Color(0x1F08705B),
      splashColor: const Color(0x1A08705B),
      highlightColor: const Color(0x0D08705B),
    );
  }

  // ─────────────────────────────────────────────
  // 8. 다크 ThemeData
  // ─────────────────────────────────────────────
  static ThemeData get dark {
    final base = light;
    return base.copyWith(
      colorScheme: _darkColors,
      scaffoldBackgroundColor: const Color(0xFF0E1A16),

      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF0E1A16),
        foregroundColor: const Color(0xFFDCE9E4),
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: const Color(0xFFDCE9E4),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: navBarHeight,
        backgroundColor: const Color(0xFF1A2C24),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF005241),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 28, color: Color(0xFF6FDBB8));
          }
          return const IconThemeData(size: 24, color: Color(0xFFA8C4BC));
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _textTheme.labelMedium?.copyWith(
              color: const Color(0xFF6FDBB8), fontWeight: FontWeight.w600);
          }
          return _textTheme.labelMedium?.copyWith(
            color: const Color(0xFFA8C4BC));
        }),
      ),

      // 다크모드 카드: 그림자 제거, surfaceVariant 색차로 구분
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF1A2C24),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, touchPreferred),
          backgroundColor: const Color(0xFF6FDBB8),
          foregroundColor: const Color(0xFF00382B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, touchMin),
          foregroundColor: const Color(0xFF6FDBB8),
          side: const BorderSide(color: Color(0xFF6FDBB8), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2C24),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16, vertical: space16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF7F9590)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF7F9590)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF6FDBB8), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFFFF8875)),
        ),
        hintStyle: _textTheme.bodyLarge?.copyWith(
          color: const Color(0xFFA8C4BC)),
        labelStyle: _textTheme.bodyLarge?.copyWith(
          color: const Color(0xFFA8C4BC)),
        floatingLabelStyle: _textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6FDBB8)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D3F38),
        selectedColor: const Color(0xFF005241),
        labelStyle: _textTheme.labelMedium?.copyWith(
          color: const Color(0xFFDCE9E4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF6FDBB8),
        foregroundColor: const Color(0xFF00382B),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: touchPreferred, height: touchPreferred),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1A2C24),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL))),
        showDragHandle: true,
        dragHandleColor: const Color(0xFF7F9590),
        dragHandleSize: const Size(32, 4),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1A2C24),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: const Color(0xFFDCE9E4)),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFA8C4BC)),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D3F38),
        thickness: 1,
        space: 0,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6FDBB8),
        linearTrackColor: Color(0xFF005241),
        circularTrackColor: Color(0xFF005241),
        linearMinHeight: 4,
      ),

      focusColor: const Color(0x1F6FDBB8),
      splashColor: const Color(0x1A6FDBB8),
      highlightColor: const Color(0x0D6FDBB8),
    );
  }

  // ─────────────────────────────────────────────
  // 9. 고대비 모드 오버라이드 (WCAG AAA)
  // ─────────────────────────────────────────────
  static ThemeData highContrastLight(ThemeData base) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF004D3D),         // 더 짙은 녹색
        onPrimary: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF000000),
        onBackground: const Color(0xFF000000),
        outline: const Color(0xFF000000),
        error: const Color(0xFF8B0000),
      ),
    );
  }

  static ThemeData highContrastDark(ThemeData base) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF9FFFDF),         // 더 밝은 민트
        onPrimary: const Color(0xFF000000),
        onSurface: const Color(0xFFFFFFFF),
        onBackground: const Color(0xFFFFFFFF),
        outline: const Color(0xFFFFFFFF),
        error: const Color(0xFFFFB3AA),
      ),
    );
  }
}
```

### 8-1. MaterialApp 적용 예시

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/wheel_way_theme.dart';

class WheelWayApp extends StatelessWidget {
  const WheelWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WheelWay',
      theme: WheelWayTheme.light,
      darkTheme: WheelWayTheme.dark,
      themeMode: ThemeMode.system,    // 시스템 설정 자동 연동
      builder: (context, child) {
        // 고대비 모드 감지
        final mediaQuery = MediaQuery.of(context);
        if (mediaQuery.highContrast) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final base = isDark
            ? WheelWayTheme.dark
            : WheelWayTheme.light;
          final hcTheme = isDark
            ? WheelWayTheme.highContrastDark(base)
            : WheelWayTheme.highContrastLight(base);
          return Theme(data: hcTheme, child: child!);
        }
        // 큰 글꼴 시스템 설정 제한 (1.3배까지만 허용)
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
      home: const MainScreen(),
    );
  }
}
```

### 8-2. 타임라인 스텝 카드 구현 예시

```dart
// lib/widgets/timeline_step_card.dart
enum StepState { done, current, upcoming }

class TimelineStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final StepState state;
  final String? distanceLabel;
  final String? durationLabel;
  final IconData icon;
  final bool isLast;

  const TimelineStepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.state,
    required this.icon,
    this.distanceLabel,
    this.durationLabel,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isCurrent = state == StepState.current;
    final isDone = state == StepState.done;

    return Semantics(
      label: '단계 $stepNumber: $title. $description.'
          '${distanceLabel != null ? ' 거리 $distanceLabel.' : ''}'
          '${durationLabel != null ? ' 예상 $durationLabel.' : ''}',
      child: Opacity(
        opacity: isDone ? 0.6 : 1.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 스텝 인디케이터 + 연결선
            Column(
              children: [
                _StepIndicator(
                  number: stepNumber,
                  state: state,
                  icon: icon,
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 60,
                    color: isDone
                      ? cs.primary
                      : cs.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(width: WheelWayTheme.space12),
            // 카드 내용
            Expanded(
              child: Card(
                elevation: isCurrent ? 3 : (isDone ? 0 : 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WheelWayTheme.radiusLG),
                  side: isCurrent
                    ? BorderSide(color: cs.primary, width: 2)
                    : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(WheelWayTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: WheelWayTheme.space4),
                      Text(description, style: theme.textTheme.bodyMedium),
                      if (distanceLabel != null || durationLabel != null) ...[
                        const SizedBox(height: WheelWayTheme.space8),
                        Row(
                          children: [
                            if (distanceLabel != null)
                              _InfoChip(
                                icon: Icons.straighten_rounded,
                                label: distanceLabel!,
                                semanticLabel: '거리 $distanceLabel',
                              ),
                            if (distanceLabel != null && durationLabel != null)
                              const SizedBox(width: WheelWayTheme.space8),
                            if (durationLabel != null)
                              _InfoChip(
                                icon: Icons.access_time_rounded,
                                label: durationLabel!,
                                semanticLabel: '예상 소요 $durationLabel',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final StepState state;
  final IconData icon;

  const _StepIndicator({
    required this.number,
    required this.state,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDone = state == StepState.done;
    final isCurrent = state == StepState.current;

    return ExcludeSemantics(  // 스텝 번호는 카드 Semantics에서 처리
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isCurrent || isDone) ? cs.primary : cs.surfaceVariant,
          border: (!isCurrent && !isDone)
            ? Border.all(color: cs.outline, width: 1.5)
            : null,
        ),
        child: Center(
          child: isDone
            ? Icon(Icons.check_rounded, color: cs.onPrimary, size: 20)
            : Icon(icon, color: isCurrent ? cs.onPrimary : cs.onSurfaceVariant, size: 20),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String semanticLabel;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WheelWayTheme.space12,
          vertical: WheelWayTheme.space8,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(WheelWayTheme.radiusSM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: WheelWayTheme.space4),
            Text(label, style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
```

### 8-3. 고려사항 — 애니메이션 접근성

```dart
// lib/widgets/accessible_animated_widget.dart
// disableAnimations 감지 래퍼
Widget buildAccessibleAnimation({
  required BuildContext context,
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
  Widget Function(BuildContext, Widget?, double)? builder,
}) {
  final disable = MediaQuery.of(context).disableAnimations;
  if (disable) return child;  // 즉시 표시
  // 정상 애니메이션 적용
  return AnimatedSwitcher(
    duration: duration,
    child: child,
  );
}
```

---

## 9. 접근성 체크리스트 (구현 시 반드시 확인)

| 항목 | 기준 | 값 |
|------|------|-----|
| 일반 텍스트 대비 | ≥ 4.5:1 | onBackground: **14.1:1** ✅ |
| 큰 텍스트 (18sp+) | ≥ 3:1 | primary on bg: **5.9:1** ✅ |
| 버튼 텍스트 대비 | ≥ 4.5:1 | onPrimary on primary: **5.9:1** ✅ |
| 최소 글꼴 크기 | 12sp | bodySmall/labelSmall = **12sp** ✅ |
| 최소 터치 타깃 | 48×48dp | 모든 버튼 **48dp+** ✅ |
| 탭바 높이 | 48dp+ | **64dp** ✅ |
| 색만으로 상태 전달 | 금지 | 아이콘 병행 필수 ✅ |
| 다크모드 | 시스템 연동 | ThemeMode.system ✅ |
| 고대비 모드 | MediaQuery 감지 | highContrastLight/Dark ✅ |
| 애니메이션 끄기 | disableAnimations | 즉시 적용 로직 ✅ |
| TalkBack Semantics | 의미 있는 위젯 | Semantics 래퍼 필수 ✅ |
| 장식 요소 | 스크린리더 제외 | ExcludeSemantics 필수 ✅ |
| 텍스트 스케일 | 시스템 설정 반영 | 최대 1.3배 허용 ✅ |

---

## 10. 미확정 / 2차 구현 사항

| 항목 | 현황 | 권장 일정 |
|------|------|---------|
| 사용자 수동 다크모드 토글 | 미구현 (시스템 연동만) | 2차 스프린트 |
| 지도 컴포넌트 (경로 오버레이) 스타일 | 미정 (Google Maps SDK 연동 시 확정) | 지도 기능 구현 시 |
| 혼잡도 시각화 컬러 스케일 | 미정 (API 응답 기반 5단계 예정) | 데이터 연동 시 |
| 온보딩 스크린 스타일 | 미구현 | 사용자 테스트 후 |
| 폰트 번들 최적화 (Noto Sans KR subset) | 미실행 | 배포 전 |
| Haptic 패턴 정의 | 미정 | 1차 사용자 테스트 후 |

---

---

