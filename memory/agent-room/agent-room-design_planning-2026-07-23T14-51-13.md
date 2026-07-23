# 디자인기획팀 Report

**Topic:** WheelWay Flutter 앱(교통약자 지하철 지름길 안내)의 기존 화면 UX 구조 개선. 이미 '에메랄드 클리어' 디자인 시스템(색/타이포/간격 토큰, ThemeData)은 확정되어 있고 그대로 유지할 것 — 이번엔 구조만 재설계. 현재 문제 3가지: (1) 타임라인·역 접근성 화면이 문장 나열식이라 텍스트 위주로 느껴짐(예: '🛗 출구 1 · 역삼 방면8-1' 같은 줄글), 시각 계층/아이콘·배지 활용 부족. (2) 역 선택 바텀시트가 240개 역을 가나다순으로만 나열해 호선별로 빠르게 찾을 수 없음 — 노선 필터 UX 필요. (3) 위 두 문제가 겹쳐 전반적으로 스크롤 압박이 심함. 탭 구조: 지름길 찾기(프로필 선택+출발/도착역+결과 타임라인)/역 접근성(역별 엘리베이터·에스컬레이터 리스트)/데이터 정보. 목표: 정보 밀도를 낮추고 호선별 필터링이 가능하며 스크롤이 짧아지는 화면 구조 설계 가이드 도출.
**Total Rounds:** 4
**Date:** 2026-07-23

---

## Round 1 — Stage 1: 서비스 분석가 ✅

> **Passed → Stage 2**

### 1. 서비스 핵심 목적 및 타겟 사용자

**서비스명:** WheelWay  
**핵심 목적:** 교통약자(휠체어·목발·스쿠터 이용자)가 서울 지하철 240개 역에서 지상 진입→승차 칸→환승→지상 진출까지 **가장 짧고 엘리베이터가 확보된 경로**를 한눈에 파악하도록 지원  

**타겟 사용자층:**
| 구분 | 내용 |
|------|------|
| 연령대 | 20대~60대 (이동약자 본인 + 보호자) |
| 사용 맥락 | 외출 직전 또는 이동 중 / 한손 조작 / 빠른 판단 필요 |
| 모빌리티 프로필 | 목발·수동휠체어·전동휠체어 3종 (코드 확인됨) |
| 기술 수준 | 중간~낮음 → 한 번에 이해 가능한 시각 계층 필수 |

---

### 2. 현재 코드에서 확인된 UX 문제 (직접 독해)

#### 문제 ①: `journey_timeline.dart` — 텍스트 나열식 타임라인

```dart
// 현재: 이모지 + 텍스트 줄글
Text('🛗 출구 ${e.exit} · ${e.detail}')  // _ElevatorList
Text('🚪 ${c.door} · ${c.toward}')       // _CarList (Wrap 칩)
```

- `_ElevatorList`는 줄글(Text만), `_CarList`는 Wrap 칩 → **두 컴포넌트가 시각 언어가 달라** 통일성 없음  
- `_TimelineStep`의 연결선 원형 인디케이터(16×16dp)가 작아 **단계 구분 인지 약함**  
- `trailing`(소요 분) 텍스트가 labelMedium으로 너무 작음  
- 엘리베이터 위치 정보가 plain Text라 아이콘·배지 활용 전혀 없음

#### 문제 ②: `station_picker.dart` — 240역 단순 나열

```dart
final list = q.isEmpty
    ? kStations          // 검색어 없으면 전체 240개 그대로 출력
    : kStations.where((s) => s.name.contains(q)).toList();
```

- **호선 필터 없음** → 가나다순 240개 전체 스크롤이 유일한 탐색 수단  
- `_LineBadge` 위젯(호선 색 원형)이 이미 구현되어 있어 **필터 탭 추가 여지 충분**  
- 바텀시트 높이: `0.8 * screen height` 고정 → 중간 반만 열리는 peek 상태 없음

#### 문제 ③: `route_search_screen.dart` + `station_access_screen.dart` — 스크롤 압박

- `route_search_screen`: `ListView` 단일 스크롤 안에 **프로필 선택 + 역 선택 + 결과 타임라인**이 모두 직렬 나열 → 결과 확인 시 상단 입력 영역까지 다시 스크롤  
- `station_access_screen`: 텍스트 필드 + 조회 버튼 → `_FacilityTile`(카드) 나열. **호선 구분, 시설 종류 필터 없음**, 결과가 많아지면 끝없는 스크롤  

---

### 3. 경쟁/유사 서비스 벤치마크 (5개)

| # | 서비스 | 타임라인 처리 | 역 필터 UX | 스크롤 전략 |
|---|--------|------------|-----------|------------|
| 1 | **카카오맵 지하철** | 단계별 카드 + 호선 색 배지, 핵심 수치(분) 강조 | 호선 탭 필터 | 경로 요약 카드 고정, 상세는 하위 확장 |
| 2 | **네이버 지도 지하철** | 세로 타임라인 + 역명·칸번 아이콘 배지 분리 | 검색+인기역 섹션 | 결과 카드 고정 + 하단 시트 |
| 3 | **지하철종결자(Smarter Subway)** | 노선도 기반 시각 + 텍스트 병행 | 호선 버튼 탭 필터 | 즐겨찾기·최근 역 섹션으로 스크롤 단축 |
| 4 | **휠세상(서울시 교통약자 앱)** | 텍스트 중심, 아이콘 보조 | 없음(검색만) | 단일 스크롤, 압박 높음 |
| 5 | **MTA 뉴욕 공식 앱** | 접근성 엘리베이터 상태 배지 강조 | 노선(A/C/E 등) 칩 필터 | 상단 고정 검색바 + 필터 칩 영역 분리 |

**트렌드 도출:**
- 주류: **호선 컬러 칩 필터** → 즉각 목록 축소  
- 타임라인은 **아이콘 아이덴티티 일관화** + 핵심 수치(분·칸번호) 배지화  
- 스크롤 압박 해소 → **입력 영역 고정 + 결과 영역 독립 스크롤** (SliverAppBar 또는 헤더 고정 패턴)

---

### 4. 브랜드 정체성 & 톤앤매너 (확정 디자인 시스템 기반)

| 항목 | 값 |
|------|---|
| 시스템명 | 에메랄드 클리어 |
| Primary | `#08705B` (에메랄드 딥그린) |
| Secondary | `#B45400` (웜 앰버) — 강조·경고 |
| 배경 | `#F8FAF7` (밀키 민트화이트) |
| 브랜드 감정 | **신뢰·명료·따뜻함** — "내가 갈 수 있는 길을 정확히 알려준다" |
| 접근성 원칙 | WCAG 2.1 AA+, 색+아이콘+텍스트 3중 병행 |
| 호선 색 | 서울교통공사 공식 1~8호선 색상 이미 토큰화됨 |

→ 이번 구조 개선은 **이 토큰을 해치지 않고** 시각 계층과 컴포넌트 구조만 재설계

---

### 5. 플랫폼·기술 제약 정리

| 항목 | 제약 |
|------|------|
| 플랫폼 | Flutter (Android 우선, iOS 지원) |
| 화면 | 모바일 세로 / 한손 조작 고려 |
| 바텀시트 | `showModalBottomSheet` — `DraggableScrollableSheet`로 교체 가능 |
| 탭 | `NavigationBar` 3탭 고정 (지름길/역 접근성/데이터) |
| 상태관리 | `setState` (단순 로컬) — 복잡 리팩 불필요 |
| 데이터 | 240개 역 정적 리스트(`kStations`) + `lines` 필드 이미 있음 |
| 최대 파일 | 500줄 제한 (CLAUDE.md) — 큰 위젯 분리 필요 |

---

### 6. 개선 방향 요약 (2단계 UX 구조 설계로 넘김)

1. **타임라인:** 줄글 → **역할별 아이콘 배지 카드** (엘리베이터=chip, 칸번호=강조 숫자 배지, 소요시간=우상단 Lozenge)
2. **역 선택 바텀시트:** 검색창 아래 **호선 필터 칩(1~8호선)** + DraggableScrollableSheet로 snapping peek 지원
3. **레이아웃:** 검색 입력 영역 → `SliverAppBar`/고정 헤더로 분리, 결과만 독립 스크롤 — 전체 스크롤 depth 50% 이상 단축 목표

---

---

## Round 2 — Stage 2: 디자인 전략가 ✅

> **Passed → Stage 3**

> ⚠️ **전제 확인**: 에메랄드 클리어 토큰(Primary `#08705B`, Secondary `#B45400`, 배경 `#F8FAF7`, 호선별 색상 등) 및 ThemeData는 **전혀 수정하지 않음**. 이번 전략은 **구조·레이아웃·컴포넌트 배치**만 다룬다.

---

### 1. 레이아웃 시스템 원칙

| 항목 | 결정값 | 근거 |
|------|--------|------|
| 그리드 | 4-column / 8dp 베이스 그리드 | Flutter Material 표준, 모바일 세로 최적 |
| 기본 여백 | 수평 패딩 16dp, 섹션 간격 12dp | 손가락 너비 기준 |
| 터치 타겟 | 최소 48×48dp | WCAG 2.5.5 / Material 가이드라인 |
| 카드 라운드 | 12dp (입력) / 8dp (리스트 아이템) | 브랜드 "부드럽지만 명료함" |
| 그림자 | elevation 1 (카드) / 0 (칩) / 3 (FAB·시트) | 플랫 기조 + 계층 최소 분리 |
| 모드 대응 | 라이트 우선 / 다크는 토큰 surfaceVariant 교체로 대응 | 기존 ThemeData 확장 |
| 반응형 | **모바일 퍼스트** 단일 브레이크포인트 (360dp / 480dp+) | 교통약자 스마트폰 집중 |

---

### 2. 화면별 구조 재설계 가이드

#### 화면 A: `journey_timeline` — 타임라인

**현재 구조:**
```
Text('🛗 출구 1 · 역삼 방면 8-1')  // 줄글
Text('🚪 8-1 · 강남 방면')          // Wrap 칩 (스타일 불일치)
```

**목표 구조 (공통):**
```
[연결선] ─ [아이콘 배지] ─ [스텝 카드]
                              ├ 타이틀(bodyLarge, semibold)
                              ├ 서브(bodySmall, onSurfaceVariant)
                              └ 우상단: 소요시간 Lozenge chip
```

**컴포넌트 계층:**
```
TimelineStep
  ├── StepConnector (vertical line, 2dp, colorScheme.outlineVariant)
  ├── StepIconBadge (40dp circle, 배경=호선색or시설색, 아이콘=Material Icons)
  │     elevator_outlined / directions_transit / transfer_within_a_station
  └── StepCard (elevation:1, borderRadius:12)
        ├── StepTitle    (bodyLarge, fontWeight.w600)
        ├── StepSubtitle (bodySmall, color: onSurfaceVariant)
        └── DurationLozenge (컨테이너 칩, primary색, 상단우)
```

---

#### 화면 B: `station_picker` — 역 선택 바텀시트

**현재 구조:**
```
BottomSheet(height: 0.8) → SearchBar → ListView(240개 가나다순)
```

**목표 구조 (공통):**
```
DraggableScrollableSheet(snap: true, snapSizes: [0.5, 0.85])
  ├── DragHandle (4dp pill)
  ├── SearchBar (고정, 포커스 시 키보드 올라와도 유지)
  ├── LineFilterRow (수평 스크롤 칩 OR 2×4 그리드)  ← 신규
  └── IndependentScrollArea
        ├── RecentSection (최근 선택 역 3개, 검색어 없을 때)
        └── FilteredStationList (선택 호선 기준 필터링)
```

**핵심 로직 추가 (Dart pseudo):**
```dart
// lines 필드가 이미 Station에 있음 → 필터만 추가
String? _selectedLine;
final filtered = _selectedLine == null
  ? kStations.where((s) => s.name.contains(q))
  : kStations.where((s) => s.lines.contains(_selectedLine) && s.name.contains(q));
```

---

#### 화면 C: `route_search_screen` — 지름길 찾기

**현재 구조:**
```
ListView (단일)
  ├── ProfileSelector
  ├── DepartureStationCard
  ├── ArrivalStationCard
  └── ResultTimeline (스크롤 압박)
```

**목표 구조 (공통):**
```
Scaffold
  ├── (고정) RouteInputHeader  ← SliverAppBar 또는 Column + Shadow
  │     ├── ProfileSelector (Horizontal chip row)
  │     └── StationSelector (From/To Row, 스왑 버튼 포함)
  └── (독립 스크롤) ResultBody
        ├── SummaryCard (총 소요시간 + 환승 횟수, 강조 숫자)
        └── TimelineList (분리 스크롤)
```

---

#### 화면 D: `station_access_screen` — 역 접근성

**현재 구조:**
```
TextField + Button → FacilityTile ListView
```

**목표 구조 (공통):**
```
Scaffold
  ├── (고정) StationSearchHeader
  ├── (고정) FacilityTypeFilter (Chip: 엘리베이터 / 에스컬레이터 / 전체)  ← 신규
  └── (독립 스크롤) FacilityList
        └── FacilityTile (아이콘 + 위치 + 상태 뱃지)
```

---

### 3. 두 가지 디자인 컨셉 비교

---

#### 컨셉 A — **"스텝 카드"** (Step Card System)

> 키워드: 명료함 · 단계별 시각 분리 · 정보 밀도 균형

| 영역 | 처리 방식 |
|------|----------|
| **타임라인** | 각 단계 = 독립 Card 위젯 (elevation 1). 아이콘 배지가 단계 의미를 선명하게 표현. 연결선은 카드 왼쪽 Border처럼 구현 |
| **역 선택** | 검색바 아래 **수평 스크롤 호선 칩 바** (1호선~8호선 + "전체"). 칩 활성 시 호선색 fill + white text. `_LineBadge` 기존 색상 그대로 재활용 |
| **입력/결과 분리** | `SliverAppBar`(pinned:true) + `SliverList` 조합. 헤더 고정, 결과만 스크롤 |
| **역 접근성 필터** | 상단 Segmented Button 3개 (전체/엘리베이터/에스컬레이터) |
| **스크롤 예상 절감** | 타임라인 밀도 ↓30%, 역 선택 평균 스크롤 ↓60% (필터로 목록 1/8 축소) |

**적합한 경우:** 기존 Material 3 컴포넌트(Card, Chip, SliverAppBar)를 최대 재활용, 구현 공수 최소, 접근성 보조기술 호환성 우수

**레이아웃 스케치:**
```
┌──────────────────────────┐
│ [≡ WheelWay]   [프로필▾] │  ← Pinned AppBar
│ [강남역 ⇄ 역삼역]  [🔍]  │
├──────────────────────────┤
│ ┌──────────────────────┐ │
│ │ ⏱ 총 8분  환승 없음  │ │  ← SummaryCard
│ └──────────────────────┘ │
│ ●━━━━━━━━━━━━━━━━━━━━━  │
│ ┌──────────────────────┐ │
│ │🛗 출구 1          2분│ │  ← StepCard
│ │  역삼 방면 엘리베이터│ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │🚇 8-1번 칸        6분│ │
│ │  강남 방면           │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

---

#### 컨셉 B — **"요약+드릴다운"** (Summary + Drill-down)

> 키워드: 최소 스크롤 · 점진적 정보 공개 · 탐색 중심

| 영역 | 처리 방식 |
|------|----------|
| **타임라인** | 기본: 한 줄 요약 Row(아이콘+역명+분). 탭 시 `AnimatedContainer`로 상세 펼침. 결과 전체가 화면 1개 안에 들어오는 컴팩트 기본 뷰 |
| **역 선택** | 검색바 위에 **2×4 호선 색상 원형 그리드** (1~8호선). 선택 시 목록 교체. 큰 터치 타겟(64dp) → 교통약자 친화 |
| **입력/결과 분리** | `Column` 고정 헤더 + `Expanded` 결과 영역 (SliverAppBar 없이 단순 구조) |
| **역 접근성 필터** | 호선 필터 + 시설 필터 2-row Chip 조합 |
| **스크롤 예상 절감** | 타임라인 기본 뷰 ↓70% (접힌 상태), 역 선택 그리드 방식으로 검색 없이도 빠른 접근 |

**적합한 경우:** 정보량이 많은 복잡한 경로에서 압도감 제거, 사용자가 원하는 단계만 펼침. 단, 애니메이션 구현 공수 추가

**레이아웃 스케치:**
```
┌──────────────────────────┐
│ [강남역 ⇄ 역삼역]  [↕]  │  ← Fixed Header
│ [목발 👤] [휠체어 👤]    │
├──────────────────────────┤
│ ⏱ 총 8분  환승 없음      │  ← Summary Row
├──────────────────────────┤
│ 🛗 출구 1  역삼방면  2분 ▾│  ← Collapsed Step
│ ─────────────────────── │
│   엘리베이터 위치: 8-1  │  ← Expanded Detail
│   운행상태: 정상          │
├──────────────────────────┤
│ 🚇 8-1번 칸  강남방면 6분▸│  ← Collapsed Step
└──────────────────────────┘
```

---

### 4. 컨셉 비교 매트릭스

| 기준 | 컨셉 A (스텝 카드) | 컨셉 B (요약+드릴다운) |
|------|------------------|---------------------|
| 초기 스크롤 길이 | 중 (카드별 고정 높이) | 최소 (접힌 상태) |
| 정보 즉시성 | 높음 (모든 정보 노출) | 낮음 (탭해야 확인) |
| 구현 공수 | ⭐⭐⭐ (낮음) | ⭐⭐⭐⭐ (중간, 애니메이션) |
| 접근성 호환 | 우수 (선형 구조) | 주의 (펼침 상태 TalkBack 대응 필요) |
| 역 선택 UX | 칩 필터 (직관적) | 그리드 (시각적, 큰 타겟) |
| 노인/저시력 | ✅ 명확한 카드 경계 | ⚠️ 접힘 상태 인지 어려울 수 있음 |
| **추천** | ✅ **1차 구현 추천** | 2차 고도화 단계 |

---

### 5. 다크모드 대응 전략

기존 토큰을 활용한 시멘틱 매핑 (새 색상 추가 없음):

```
라이트                     다크
─────────────────────────────────────
surface: #F8FAF7     →  surface: #121212
card bg: white       →  surfaceVariant: #1E2A28
아이콘 배지 bg:       →  동일 호선색 (opacity 0.85)
연결선: outlineVariant →  outlineVariant (자동 조정)
```

→ ThemeData의 `colorScheme.brightness` 분기만으로 대응 가능

---

### 6. 반응형 전략

```
360dp 미만: 칩 row → icon only (텍스트 숨김, tooltip 제공)
360~480dp : 기본 레이아웃 (타겟 디바이스)
480dp 이상: 카드 max-width 480dp + 중앙 정렬 (태블릿 대비)
```

---

### 7. 3단계로 넘길 핵심 컴포넌트 목록

| 컴포넌트명 | 파일 | 우선순위 |
|-----------|------|---------|
| `StepIconBadge` | journey_timeline.dart 분리 | P0 |
| `StepCard` | journey_timeline.dart 분리 | P0 |
| `LineFilterChipRow` | station_picker.dart 신규 | P0 |
| `DraggableStationSheet` | station_picker.dart 교체 | P0 |
| `RouteInputHeader` (pinned) | route_search_screen.dart 분리 | P1 |
| `RouteSummaryCard` | route_search_screen.dart 신규 | P1 |
| `FacilityTypeFilter` | station_access_screen.dart 신규 | P1 |

---

---

## Round 3 — Stage 3: 스타일 검증자 ✅

> **Passed → Stage 4**

### 1. 서비스 목적·타겟 일치도

| 검증 항목 | 컨셉 A (스텝 카드) | 컨셉 B (요약+드릴다운) | 판정 |
|-----------|------------------|---------------------|------|
| 한손 조작·빠른 판단 | 모든 정보 즉시 노출, 스크롤 방향 단순 | 탭해야 펼침 → 조작 단계 추가 | A ✅ / B ⚠️ |
| 노인·저시력 친화 | 카드 경계 명확, 선형 구조 | 접힘 상태 인지 어려울 수 있음 | A ✅ / B ⚠️ |
| 이동 중 긴급 조회 | SliverAppBar 고정 → 항상 입력 접근 가능 | Column 고정 헤더로 동등 | A ✅ / B ✅ |
| 모빌리티 3종 분기 | ProfileSelector 칩 유지, 구조 변화 없음 | 동일 | 양쪽 ✅ |

→ **타겟 적합성: 컨셉 A 우세**. 교통약자는 실시간 이동 중 사용하므로 정보 즉시성(모든 단계 노출)이 접힌 상태보다 안전.

---

### 2. 접근성 검증 (WCAG AA 기준)

#### 색상 대비

| 조합 | 대비비 | WCAG AA (4.5:1) | 비고 |
|------|--------|----------------|------|
| Primary `#08705B` / white | **5.48:1** | ✅ | AppBar·칩 텍스트 |
| Primary `#08705B` / `#F8FAF7` | **5.21:1** | ✅ | 배경 위 버튼 |
| Secondary `#B45400` / white | **4.74:1** | ✅ 간신히 | 경고 배지 |
| **⚠️ DurationLozenge (white text on `#08705B`)** | **5.48:1** | ✅ | 역순도 통과 |
| **⚠️ 호선 칩 — 1호선 (`#0052A4`) / white 텍스트** | **7.2:1** | ✅ | |
| **⚠️ 호선 칩 — 3호선 (`#EF7C1C`) / white 텍스트** | **2.9:1** | ❌ **실패** | 오렌지 계열은 흰 텍스트 불가 |

> **⚠️ 필수 수정**: 3호선(오렌지)·9호선(금색) 계열 호선 칩은 **흰 텍스트 대신 `#1A1A1A` 다크 텍스트**로 전환해야 WCAG AA 통과. 서울교통공사 공식 색상 중 밝은 계열(3·5·9호선 일부)이 이 패턴에 해당.

#### 터치 영역

| 컴포넌트 | 명시된 크기 | WCAG 2.5.5 (48dp) | 판정 |
|----------|-----------|-------------------|------|
| StepIconBadge | **40dp circle** (아이콘 자체) | 터치 타겟 ≠ 아이콘 크기 | ⚠️ Padding 추가 필요 |
| 호선 칩 (컨셉 A) | 미명시 | 48dp height 보장 필요 | 조건부 ✅ |
| 호선 원형 그리드 (컨셉 B) | **64dp** | ✅ | 명확히 초과 |
| Segmented Button | Material 3 기본 48dp | ✅ | |

> **⚠️ 필수 수정**: `StepIconBadge`는 아이콘 40dp + `Padding(all: 4dp)` = 총 48dp 터치 영역을 `InkWell` 또는 `GestureDetector`로 감싸야 함.

#### 폰트 가독성

- `bodyLarge` 타이틀 + `bodySmall` 서브라인 조합 → 계층 명확 ✅
- `labelMedium` 소요시간 → 전략에서 Lozenge chip으로 대체됨으로 기존 문제 해소 ✅

---

### 3. 기술적 구현 가능성

| 컴포넌트 | Flutter API | 상태관리 | 500줄 제한 | 판정 |
|----------|-------------|---------|-----------|------|
| `DraggableScrollableSheet(snap, snapSizes)` | Flutter 2.5+ 기본 제공 | setState | 별도 파일 분리 필요 | ✅ |
| `SliverAppBar(pinned: true)` | Material 기본 | setState | route_search_screen 내 | ✅ |
| `LineFilterChipRow` + `_selectedLine` 필터 | 기존 `_LineBadge` 재활용 | setState | station_picker 분리 | ✅ |
| `AnimatedContainer` 펼침 (컨셉 B) | 기본 제공이나 TalkBack semantics 별도 처리 | setState + bool list | 복잡도 ↑ | ⚠️ |
| 최근 역 섹션 | SharedPreferences 또는 in-memory | setState | 신규 유틸 | 조건부 ✅ |

> 컨셉 B의 `AnimatedContainer` 확장·축소 시 **Semantics 위젯으로 `expanded: true/false` 상태를 TalkBack에 노출**하지 않으면 접근성 보조기술 사용자가 내용 유무를 인지 못함. 구현 공수 대비 리스크.

---

### 4. 일관성 및 디자인 시스템 확장성

**긍정 요소:**
- 에메랄드 클리어 토큰 무수정 유지 → 기존 ThemeData 완전 호환 ✅
- `StepIconBadge` → `StepCard` → `LineFilterChipRow` 컴포넌트 계층이 독립성 높아 재사용 용이 ✅
- `elevation 1(카드) / 0(칩) / 3(시트)` 단계 명시로 깊이 체계 통일 ✅
- 다크모드 토큰 매핑이 `colorScheme.brightness` 분기만으로 완결 → 신규 색상 추가 없음 ✅

**보완 필요:**
- StepCard의 `borderRadius: 12dp`(입력) vs `8dp`(리스트) 구분이 타임라인 Step 카드에는 명확히 적용되지 않음 → **타임라인 StepCard는 8dp 통일 권고** (리스트 아이템 범주)
- 반응형 전략에서 360dp 미만 `icon only` 칩 처리 시 `Tooltip` 필수 명시 → 이미 전략에 포함되어 있어 ✅

---

### 5. 경쟁사 대비 차별화

| 비교 대상 | WheelWay 차별점 |
|-----------|--------------|
| 카카오맵 지하철 | 교통약자 특화 아이콘 (🛗 엘리베이터·에스컬레이터 전용) — 일반 지하철 앱에 없는 시설 상태 배지 |
| 지하철종결자 | 노선도 없이 **텍스트 타임라인 + 칸번호 강조** → 정보 밀도 낮고 인지 부담 적음 |
| 휠세상 | 호선 필터 + 시설 종류 필터 이중 필터링 → 유사 서비스 중 유일한 구조 |
| MTA 뉴욕 | 에메랄드 클리어 브랜드 컬러 → 의료/복지 앱의 차갑고 무채색 톤 탈피, 따뜻하면서 신뢰감 |

→ **독자 아이덴티티 확보 충분**. 다만 컨셉 A의 수평 칩 필터는 카카오맵과 유사. **역 선택에서 컨셉 B의 2×4 그리드 + 큰 터치 타겟(64dp)** 방식을 채택하면 접근성·차별화 두 축 모두 강화 가능.

---

### 6. ✅ 최종 권고: **하이브리드 채택**

> 컨셉 A의 구조 안정성 + 컨셉 B의 역 선택 그리드 UX를 결합

| 화면 | 채택 컨셉 | 이유 |
|------|----------|------|
| **타임라인** | **컨셉 A** (스텝 카드) | 선형·즉시 정보 노출, TalkBack 호환, 노인 친화 |
| **역 선택 바텀시트** | **컨셉 B** (2×4 그리드 64dp) | 큰 터치 타겟 → 교통약자 직접 수혜, 차별화 |
| **입력/결과 분리** | **컨셉 A** (SliverAppBar pinned) | Material 3 표준, 접근성 보조기술 완전 지원 |
| **역 접근성 필터** | **컨셉 A** (Segmented Button) | 단순 명확, 구현 공수 최소 |

**4단계 구현 시 반드시 반영할 조건 2개:**
1. 호선 칩 중 밝은 계열(3·5·9호선 등) → 텍스트를 `#1A1A1A`(다크)로 자동 분기
2. StepIconBadge 터치 영역 = 아이콘(40dp) + Padding(4dp) = 실질 48dp 보장

---

---

## Round 4 — Stage 4: 디자인 가이드 작성자 🏆

# WheelWay 최종 디자인 가이드
## 에메랄드 클리어 × UX 구조 재설계 v1.0

---

## 0. 전제 사항

| 항목 | 내용 |
|------|------|
| 디자인 시스템 | **에메랄드 클리어** — ThemeData 변경 없음, 토큰 100% 유지 |
| 이번 가이드 범위 | 구조·레이아웃·신규 컴포넌트 코드만 추가 |
| 채택 컨셉 | **하이브리드**: 타임라인=A(스텝카드) / 역선택=B(2×4 그리드) / 입력분리=A(SliverAppBar) / 시설필터=A(SegmentedButton) |
| 필수 접근성 수정 | ① 밝은 호선(3·6·9호선) → 텍스트 `#1A1A1A` / ② StepIconBadge 터치 영역 48dp 보장 |

---

## 1. 컬러 팔레트 (확정 토큰)

### 1-1. 에메랄드 클리어 시맨틱 토큰

```dart
// lib/theme/emerald_clear_theme.dart (기존 파일 — 수정 없음, 참조용)

// ──────────────────────────────────────────────────
// LIGHT MODE
// ──────────────────────────────────────────────────
const kColorPrimary          = Color(0xFF08705B); // 에메랄드 딥그린
const kColorOnPrimary        = Color(0xFFFFFFFF);
const kColorPrimaryContainer = Color(0xFFA8F0D6);
const kColorSecondary        = Color(0xFFB45400); // 웜 앰버
const kColorOnSecondary      = Color(0xFFFFFFFF);
const kColorBackground       = Color(0xFFF8FAF7); // 밀키 민트화이트
const kColorSurface          = Color(0xFFFFFFFF);
const kColorSurfaceVariant   = Color(0xFFF0F5F0);
const kColorOnSurface        = Color(0xFF191C1A);
const kColorOnSurfaceVariant = Color(0xFF3F4945);
const kColorOutline          = Color(0xFF6F7973);
const kColorOutlineVariant   = Color(0xFFBFC9C3);

// ──────────────────────────────────────────────────
// DARK MODE (surfaceVariant 교체만으로 대응)
// ──────────────────────────────────────────────────
const kColorSurfaceDark        = Color(0xFF121212);
const kColorSurfaceVariantDark = Color(0xFF1E2A28);
```

### 1-2. 서울 지하철 호선 색상 + 텍스트 분기 ⚠️ 접근성 필수

```dart
// lib/theme/line_colors.dart

// 호선별 배경색 (서울교통공사 공식)
const Map<String, Color> kLineColors = {
  '1': Color(0xFF0052A4), // 1호선 파랑
  '2': Color(0xFF00A84D), // 2호선 초록
  '3': Color(0xFFEF7C1C), // 3호선 오렌지 ← 다크 텍스트
  '4': Color(0xFF00A5DE), // 4호선 하늘
  '5': Color(0xFF996CAC), // 5호선 보라
  '6': Color(0xFFCD7C2F), // 6호선 갈색 ← 다크 텍스트
  '7': Color(0xFF747F00), // 7호선 올리브
  '8': Color(0xFFE6186C), // 8호선 분홍
  '9': Color(0xFFBDB092), // 9호선 금색 ← 다크 텍스트
};

// ⚠️ WCAG AA 기준: 밝은 호선은 흰 텍스트 대비비 실패 → 다크 텍스트 강제
const Set<String> kLineDarkTextRequired = {'3', '6', '9'};

/// 호선 번호에 따라 텍스트 색을 자동 반환
Color lineTextColor(String line) {
  return kLineDarkTextRequired.contains(line)
      ? const Color(0xFF1A1A1A)  // 다크 텍스트
      : Colors.white;             // 화이트 텍스트
}

/// 호선 배경색 반환 (기본값: outline)
Color lineColor(String line) =>
    kLineColors[line] ?? const Color(0xFF6F7973);
```

---

## 2. 타이포그래피 스펙

> **폰트**: Noto Sans KR (Google Fonts) — 기존 ThemeData 적용값 유지

| 레벨 | 역할 | Size | Weight | Line-height | Color |
|------|------|------|--------|-------------|-------|
| `headlineMedium` | 총 소요시간 강조 숫자 | 28sp | W700 | 1.3 | primary |
| `titleLarge` | 화면 섹션 제목 | 22sp | W600 | 1.3 | onSurface |
| `titleMedium` | 카드 섹션 헤더 | 16sp | W600 | 1.4 | onSurface |
| `bodyLarge` | **StepCard 타이틀** | 16sp | W600 | 1.5 | onSurface |
| `bodyMedium` | 일반 본문 | 14sp | W400 | 1.5 | onSurface |
| `bodySmall` | **StepCard 서브타이틀** | 12sp | W400 | 1.4 | onSurfaceVariant |
| `labelLarge` | 버튼·칩 텍스트 | 14sp | W500 | 1.3 | — |
| `labelMedium` | **DurationLozenge** | 12sp | W500 | 1.2 | onPrimary |
| `labelSmall` | 보조 레이블 | 11sp | W400 | 1.2 | onSurfaceVariant |

---

## 3. 여백/간격 체계 (Spacing Scale)

```dart
// lib/theme/spacing.dart

class Spacing {
  Spacing._();

  static const double xs  = 4.0;   // 내부 아이콘 패딩
  static const double sm  = 8.0;   // 아이콘-텍스트 간격
  static const double md  = 12.0;  // 카드 내부 패딩, 섹션 간 소간격
  static const double lg  = 16.0;  // 수평 스크린 패딩 ← 기준값
  static const double xl  = 20.0;  // 카드 상하 패딩
  static const double xl2 = 24.0;  // 섹션 간 대간격
  static const double xl3 = 32.0;  // 큰 섹션 분리
  static const double xl4 = 48.0;  // 최소 터치 타겟
  static const double xl5 = 64.0;  // 호선 그리드 셀 터치 타겟
}
```

| 용도 | 값 |
|------|---|
| 화면 수평 패딩 | `16dp` |
| 카드 내부 패딩 | `12dp` (상하) / `12dp` (좌우) |
| 컴포넌트 간 간격 | `12dp` |
| 섹션 간 간격 | `24dp` |
| 최소 터치 타겟 | `48dp` (WCAG 2.5.5) |
| 호선 그리드 셀 | `64dp` |
| 카드 borderRadius | `8dp` (리스트 아이템) / `12dp` (입력 카드) |
| 바텀시트 cornerRadius | `16dp` |

---

## 4. 컴포넌트 가이드 + Flutter 구현 코드

### 4-1. `StepIconBadge` — 타임라인 아이콘 배지

**스펙:**
- 아이콘 원형 배지: `40×40dp`, `BoxShape.circle`
- 터치 영역: 아이콘 + `Padding(4dp)` = 실질 `48dp` ← WCAG 2.5.5 필수
- 아이콘 크기: `20dp` (Material Icons Outlined)
- 배경색: 시설 종류별 (엘리베이터=primary, 환승=secondaryContainer, 출입구=surfaceVariant)

```dart
// lib/widgets/step_icon_badge.dart

import 'package:flutter/material.dart';

class StepIconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String semanticLabel; // 접근성 필수

  const StepIconBadge({
    super.key,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.all(4.0), // 40 + 4*2 = 48dp 터치 영역
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 시설 종류별 프리셋 팩토리
// ──────────────────────────────────────────────
extension StepIconBadgePresets on StepIconBadge {
  static StepIconBadge elevator(BuildContext ctx) => StepIconBadge(
    icon: Icons.elevator_outlined,
    backgroundColor: Theme.of(ctx).colorScheme.primary,
    iconColor: Colors.white,
    semanticLabel: '엘리베이터',
  );

  static StepIconBadge platform(BuildContext ctx, String line) => StepIconBadge(
    icon: Icons.directions_transit_outlined,
    backgroundColor: lineColor(line),
    iconColor: lineTextColor(line),
    semanticLabel: '$line호선 승강장',
  );

  static StepIconBadge transfer(BuildContext ctx) => StepIconBadge(
    icon: Icons.transfer_within_a_station_outlined,
    backgroundColor: Theme.of(ctx).colorScheme.secondaryContainer,
    iconColor: Theme.of(ctx).colorScheme.onSecondaryContainer,
    semanticLabel: '환승',
  );

  static StepIconBadge exit(BuildContext ctx) => StepIconBadge(
    icon: Icons.exit_to_app_outlined,
    backgroundColor: Theme.of(ctx).colorScheme.surfaceVariant,
    iconColor: Theme.of(ctx).colorScheme.onSurfaceVariant,
    semanticLabel: '출구',
  );
}
```

---

### 4-2. `DurationLozenge` — 소요시간 배지

**스펙:**
- 크기: 자동 (텍스트 기준), 최소 높이 `24dp`
- 배경: `primary` (에메랄드)
- 텍스트: `labelMedium`, white
- 패딩: `H:8dp V:4dp`
- borderRadius: `12dp` (pill)

```dart
// lib/widgets/duration_lozenge.dart

import 'package:flutter/material.dart';

class DurationLozenge extends StatelessWidget {
  final int minutes;

  const DurationLozenge({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$minutes분',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color.onPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
```

---

### 4-3. `StepCard` + `TimelineConnector` — 타임라인 스텝

**스펙:**
- Card elevation: `1`
- borderRadius: `8dp`
- 내부 패딩: `12dp`
- 연결선: `2dp 너비`, `outlineVariant` 색, 좌측 `28dp` 위치(배지 중앙 정렬)
- 아이콘-텍스트 간격: `12dp`

```dart
// lib/widgets/journey/step_card.dart

import 'package:flutter/material.dart';
import 'step_icon_badge.dart';
import 'duration_lozenge.dart';

class TimelineStepCard extends StatelessWidget {
  final StepIconBadge badge;
  final String title;
  final String subtitle;
  final int? durationMinutes;
  final bool isLast;

  const TimelineStepCard({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.durationMinutes,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 연결선 + 배지 영역 ──
          SizedBox(
            width: 56, // 배지(48dp) + 좌우 여백
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 48, // 배지 높이 이후부터 시작
                    bottom: 0,
                    left: 27, // (56 - 2) / 2 = 중앙
                    child: Container(
                      width: 2,
                      color: color.outlineVariant,
                    ),
                  ),
                badge,
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── 카드 영역 ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: text.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: text.bodySmall?.copyWith(
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (durationMinutes != null) ...[
                        const SizedBox(width: 8),
                        DurationLozenge(minutes: durationMinutes!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 4-4. `RouteSummaryCard` — 경로 요약 카드

**스펙:**
- 배경: `primaryContainer` (`#A8F0D6`)
- 텍스트: `onPrimaryContainer`
- 총 소요시간 숫자: `headlineMedium` (28sp, W700)
- 환승 횟수: `bodyMedium`
- borderRadius: `12dp`
- 패딩: `16dp`

```dart
// lib/widgets/journey/route_summary_card.dart

import 'package:flutter/material.dart';

class RouteSummaryCard extends StatelessWidget {
  final int totalMinutes;
  final int transferCount;

  const RouteSummaryCard({
    super.key,
    required this.totalMinutes,
    required this.transferCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('총 소요시간', style: text.bodySmall?.copyWith(
                color: color.onPrimaryContainer,
              )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$totalMinutes',
                    style: text.headlineMedium?.copyWith(
                      color: color.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text('분', style: text.bodyMedium?.copyWith(
                    color: color.onPrimaryContainer,
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          Container(
            width: 1,
            height: 40,
            color: color.onPrimaryContainer.withOpacity(0.3),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('환승', style: text.bodySmall?.copyWith(
                color: color.onPrimaryContainer,
              )),
              Text(
                transferCount == 0 ? '없음' : '$transferCount회',
                style: text.titleMedium?.copyWith(
                  color: color.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

### 4-5. `RouteInputHeader` — 고정 입력 헤더 (SliverAppBar)

**스펙:**
- `SliverAppBar(pinned: true, floating: false, expandedHeight: 140dp)`
- ProfileSelector: 수평 칩 Row, 높이 `40dp`
- StationRow: 출발/도착 + 스왑 버튼
- 스왑 버튼: `Icons.swap_vert`, 48×48dp

```dart
// lib/widgets/journey/route_input_header.dart

import 'package:flutter/material.dart';

class RouteInputHeader extends StatelessWidget {
  final String departure;
  final String arrival;
  final String selectedProfile; // 'wheelchair' | 'crutch' | 'scooter'
  final VoidCallback onDepartureTab;
  final VoidCallback onArrivalTap;
  final VoidCallback onSwap;
  final ValueChanged<String> onProfileChanged;

  const RouteInputHeader({
    super.key,
    required this.departure,
    required this.arrival,
    required this.selectedProfile,
    required this.onDepartureTab,
    required this.onArrivalTap,
    required this.onSwap,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 148,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 모빌리티 프로필 칩
                _ProfileChipRow(
                  selected: selectedProfile,
                  onChanged: onProfileChanged,
                ),
                const SizedBox(height: 8),
                // 출발/도착 선택
                _StationSelectorRow(
                  departure: departure,
                  arrival: arrival,
                  onDepartureTap: onDepartureTab,
                  onArrivalTap: onArrivalTap,
                  onSwap: onSwap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileChipRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ProfileChipRow({required this.selected, required this.onChanged});

  static const profiles = [
    ('wheelchair', '🦽 수동휠체어'),
    ('power_wheelchair', '⚡ 전동휠체어'),
    ('crutch', '🩼 목발'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: profiles.map((p) {
          final isSelected = selected == p.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(p.$2),
              selected: isSelected,
              onSelected: (_) => onChanged(p.$1),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StationSelectorRow extends StatelessWidget {
  final String departure;
  final String arrival;
  final VoidCallback onDepartureTap;
  final VoidCallback onArrivalTap;
  final VoidCallback onSwap;

  const _StationSelectorRow({
    required this.departure,
    required this.arrival,
    required this.onDepartureTap,
    required this.onArrivalTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _StationTile(
                label: '출발',
                stationName: departure,
                onTap: onDepartureTap,
                color: color,
                text: text,
              ),
              const SizedBox(height: 4),
              _StationTile(
                label: '도착',
                stationName: arrival,
                onTap: onArrivalTap,
                color: color,
                text: text,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: onSwap,
            tooltip: '출발/도착 교환',
          ),
        ),
      ],
    );
  }
}

class _StationTile extends StatelessWidget {
  final String label;
  final String stationName;
  final VoidCallback onTap;
  final ColorScheme color;
  final TextTheme text;

  const _StationTile({
    required this.label, required this.stationName,
    required this.onTap, required this.color, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: text.labelSmall?.copyWith(color: color.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                stationName.isEmpty ? '역을 선택하세요' : stationName,
                style: text.bodyMedium?.copyWith(
                  color: stationName.isEmpty
                      ? color.onSurfaceVariant
                      : color.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 4-6. `LineFilterGrid` — 호선 2×4 그리드 (역 선택 바텀시트)

**스펙:**
- 배열: 2행 4열 (`GridView`, `crossAxisCount: 4`)
- 각 셀 터치 타겟: **64×64dp** (교통약자 직접 수혜)
- 아이콘: 호선 번호 텍스트 (`titleMedium`, W700)
- 선택 상태: `2dp` 흰 테두리 + scale 1.05
- "전체" 버튼: `outlineVariant` 배경, `onSurface` 텍스트

```dart
// lib/widgets/station_picker/line_filter_grid.dart

import 'package:flutter/material.dart';
import '../../theme/line_colors.dart';

class LineFilterGrid extends StatelessWidget {
  final String? selectedLine; // null = 전체
  final ValueChanged<String?> onLineSelected;

  const LineFilterGrid({
    super.key,
    required this.selectedLine,
    required this.onLineSelected,
  });

  static const _lines = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              ..._lines.map((line) => _LineCell(
                line: line,
                isSelected: selectedLine == line,
                onTap: () => onLineSelected(
                  selectedLine == line ? null : line, // 재탭 시 선택 해제
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          // "전체 보기" 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onLineSelected(null),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                side: BorderSide(
                  color: selectedLine == null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                foregroundColor: selectedLine == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              child: const Text('전체 노선'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineCell extends StatelessWidget {
  final String line;
  final bool isSelected;
  final VoidCallback onTap;

  const _LineCell({
    required this.line,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = lineColor(line);
    final fg = lineTextColor(line);

    return Semantics(
      label: '$line호선 필터${isSelected ? " 선택됨" : ""}',
      button: true,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            // 64×64dp 터치 타겟 보장
            constraints: const BoxConstraints(
              minWidth: 64,
              minHeight: 64,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(
                      color: bg.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )]
                  : null,
            ),
            child: Center(
              child: Text(
                '$line호선',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 4-7. `DraggableStationSheet` — 역 선택 바텀시트

**스펙:**
- `DraggableScrollableSheet(snap: true, snapSizes: [0.5, 0.85])`
- 상단: DragHandle (40×4dp pill, `outlineVariant`)
- SearchBar 고정 (`TextField`, borderRadius: 12dp)
- LineFilterGrid (신규)
- 최근 선택 섹션 (3개, 검색어 없을 때만 노출)
- 필터 결과 ListView

```dart
// lib/widgets/station_picker/draggable_station_sheet.dart

import 'package:flutter/material.dart';
import 'line_filter_grid.dart';

void showStationPicker({
  required BuildContext context,
  required String title,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.5, 0.85],
      builder: (ctx, scrollController) => _StationSheetContent(
        title: title,
        scrollController: scrollController,
        onSelected: onSelected,
      ),
    ),
  );
}

class _StationSheetContent extends StatefulWidget {
  final String title;
  final ScrollController scrollController;
  final ValueChanged<String> onSelected;

  const _StationSheetContent({
    required this.title,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  State<_StationSheetContent> createState() => _StationSheetContentState();
}

class _StationSheetContentState extends State<_StationSheetContent> {
  String _query = '';
  String? _selectedLine;

  List<Map<String, dynamic>> get _filtered {
    return kStations.where((s) {
      final matchQuery = _query.isEmpty || s['name'].contains(_query);
      final matchLine = _selectedLine == null ||
          (s['lines'] as List).contains(_selectedLine);
      return matchQuery && matchLine;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // DragHandle
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: color.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.title,
              style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          // 검색바 (고정)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '역 이름 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: color.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 호선 그리드 필터 (고정)
          LineFilterGrid(
            selectedLine: _selectedLine,
            onLineSelected: (line) => setState(() => _selectedLine = line),
          ),
          const Divider(height: 16),
          // 역 목록 (독립 스크롤)
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final station = _filtered[i];
                return ListTile(
                  title: Text(station['name']),
                  subtitle: Text(
                    (station['lines'] as List).map((l) => '$l호선').join(' · '),
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  leading: _LineBadge(lines: station['lines'] as List),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSelected(station['name']);
                  },
                  minLeadingWidth: 40,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LineBadge extends StatelessWidget {
  final List lines;
  const _LineBadge({required this.lines});

  @override
  Widget build(BuildContext context) {
    final firstLine = lines.isNotEmpty ? lines.first.toString() : '';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: lineColor(firstLine),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          firstLine,
          style: TextStyle(
            color: lineTextColor(firstLine),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
```

---

### 4-8. `FacilityTypeFilter` — 역 접근성 시설 필터

**스펙:**
- Material 3 `SegmentedButton` (3개: 전체 / 엘리베이터 / 에스컬레이터)
- 선택 상태: `primaryContainer` 배경
- 높이: `40dp`
- 전체 폭 스트레치

```dart
// lib/widgets/station_access/facility_type_filter.dart

import 'package:flutter/material.dart';

enum FacilityType { all, elevator, escalator }

class FacilityTypeFilter extends StatelessWidget {
  final FacilityType selected;
  final ValueChanged<FacilityType> onChanged;

  const FacilityTypeFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<FacilityType>(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(0, 40),
        ),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: FacilityType.all, label: Text('전체')),
          ButtonSegment(
            value: FacilityType.elevator,
            label: Text('엘리베이터'),
            icon: Icon(Icons.elevator_outlined, size: 16),
          ),
          ButtonSegment(
            value: FacilityType.escalator,
            label: Text('에스컬레이터'),
            icon: Icon(Icons.escalator_outlined, size: 16),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
```

---

### 4-9. `FacilityTile` — 시설 아이템 카드

**스펙:**
- 상태 배지: 운행중=`primary` / 점검중=`secondary` / 고장=`error`
- elevation: `1`
- borderRadius: `8dp`
- 최소 높이: `72dp` (터치 타겟)

```dart
// lib/widgets/station_access/facility_tile.dart

import 'package:flutter/material.dart';

enum FacilityStatus { operating, maintenance, outOfService }

class FacilityTile extends StatelessWidget {
  final String name;
  final String location;
  final FacilityStatus status;
  final bool isElevator; // false = 에스컬레이터

  const FacilityTile({
    super.key,
    required this.name,
    required this.location,
    required this.status,
    required this.isElevator,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 시설 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isElevator
                    ? Icons.elevator_outlined
                    : Icons.escalator_outlined,
                color: color.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 이름 + 위치
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  Text(location, style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  )),
                ],
              ),
            ),
            // 상태 배지
            _StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final FacilityStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final (label, bg, fg) = switch (status) {
      FacilityStatus.operating    => ('운행중', color.primary, color.onPrimary),
      FacilityStatus.maintenance  => ('점검중', color.secondary, color.onSecondary),
      FacilityStatus.outOfService => ('고장', color.error, color.onError),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}
```

---

## 5. 화면별 레이아웃 구현 패턴

### 5-1. `route_search_screen.dart` — 지름길 찾기

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      // ① 입력 헤더 고정 (SliverAppBar pinned)
      SliverPersistentHeader(
        pinned: true,
        delegate: _RouteInputDelegate(...), // RouteInputHeader 래핑
      ),
      
      // ② 결과 영역 (독립 스크롤)
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // 총 소요시간 요약 카드
            RouteSummaryCard(
              totalMinutes: result.totalMinutes,
              transferCount: result.transfers,
            ),
            const SizedBox(height: 12),
            // 타임라인 스텝 목록
            ...result.steps.asMap().entries.map((e) =>
              TimelineStepCard(
                badge: _badgeForStep(e.value, context),
                title: e.value.title,
                subtitle: e.value.subtitle,
                durationMinutes: e.value.minutes,
                isLast: e.key == result.steps.length - 1,
              ),
            ),
          ]),
        ),
      ),
    ],
  ),
)
```

### 5-2. `station_access_screen.dart` — 역 접근성

```dart
Scaffold(
  body: Column(
    children: [
      // ① 역 검색 헤더 (고정)
      const SizedBox(height: 16),
      StationSearchHeader(onSearch: _handleSearch),
      const SizedBox(height: 12),
      
      // ② 시설 필터 (고정)
      FacilityTypeFilter(
        selected: _facilityType,
        onChanged: (t) => setState(() => _facilityType = t),
      ),
      const SizedBox(height: 12),
      const Divider(height: 1),
      
      // ③ 시설 목록 (독립 스크롤)
      Expanded(
        child: ListView.builder(
          itemCount: _filteredFacilities.length,
          itemBuilder: (_, i) => FacilityTile(
            name: _filteredFacilities[i].name,
            location: _filteredFacilities[i].location,
            status: _filteredFacilities[i].status,
            isElevator: _filteredFacilities[i].isElevator,
          ),
        ),
      ),
    ],
  ),
)
```

---

## 6. Flutter 테마 토큰 (즉시 사용 가능)

```dart
// lib/theme/app_spacing.dart — spacing scale

class AppSpacing {
  static const double p4  = 4.0;
  static const double p8  = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;  // 화면 수평 패딩 기준
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p48 = 48.0;  // 최소 터치 타겟
  static const double p64 = 64.0;  // 호선 그리드 셀

  static const double radiusSm = 8.0;   // 리스트 카드
  static const double radiusMd = 12.0;  // 입력 카드
  static const double radiusLg = 16.0;  // 바텀시트
  static const double radiusPill = 100.0; // Lozenge/배지
}
```

```dart
// lib/theme/app_theme.dart — ThemeData (기존 유지, 참조용 핵심 발췌)

ThemeData emeraldClearTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF08705B),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF08705B),
    secondary: const Color(0xFFB45400),
    background: const Color(0xFFF8FAF7),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    ),
  ),
  chipTheme: ChipThemeData(
    showCheckmark: false,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.p8,
      vertical: AppSpacing.p4,
    ),
  ),
  // ... (나머지 기존 ThemeData 유지)
);
```

---

## 7. 다크모드 대응 (추가 토큰 없음)

```dart
// 다크모드 시 자동 분기 — 새 색상 불필요
// ThemeData에 brightness: Brightness.dark 추가 시 자동 적용

// 유일한 명시적 분기: 카드 배경
Color cardBackground(BuildContext ctx) {
  final brightness = Theme.of(ctx).brightness;
  return brightness == Brightness.dark
      ? const Color(0xFF1E2A28)  // surfaceVariant dark
      : Colors.white;
}

// 호선 배지: 동일 호선색, opacity 0.85로 다크모드 자연 조화
Color lineBadgeColor(String line, Brightness brightness) {
  final base = lineColor(line);
  return brightness == Brightness.dark
      ? base.withOpacity(0.85)
      : base;
}
```

---

## 8. 반응형 처리

```dart
// lib/utils/responsive.dart

class Responsive {
  static bool isCompact(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width < 360;

  static bool isNormal(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    return w >= 360 && w < 480;
  }

  static bool isWide(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 480;

  // 칩 텍스트 노출 여부 (360dp 미만에서 icon only)
  static bool showChipLabel(BuildContext ctx) => !isCompact(ctx);

  // 카드 최대 너비 (태블릿 대비)
  static double maxCardWidth(BuildContext ctx) =>
      isWide(ctx) ? 480 : double.infinity;
}
```

---

## 9. 구현 체크리스트

| # | 항목 | 파일 | 우선순위 |
|---|------|------|---------|
| 1 | `StepIconBadge` 분리 + 48dp 터치 보장 | `widgets/step_icon_badge.dart` | **P0** |
| 2 | `TimelineStepCard` 분리 + 연결선 | `widgets/journey/step_card.dart` | **P0** |
| 3 | `DurationLozenge` 분리 | `widgets/duration_lozenge.dart` | **P0** |
| 4 | `LineFilterGrid` 신규 (2×4, 64dp) | `widgets/station_picker/line_filter_grid.dart` | **P0** |
| 5 | `DraggableStationSheet` 교체 | `widgets/station_picker/draggable_station_sheet.dart` | **P0** |
| 6 | 호선 밝은 색 텍스트 `#1A1A1A` 분기 | `theme/line_colors.dart` | **P0** |
| 7 | `RouteInputHeader` 고정 헤더 | `widgets/journey/route_input_header.dart` | **P1** |
| 8 | `RouteSummaryCard` 신규 | `widgets/journey/route_summary_card.dart` | **P1** |
| 9 | `FacilityTypeFilter` 신규 | `widgets/station_access/facility_type_filter.dart` | **P1** |
| 10 | `FacilityTile` 상태 배지 추가 | `widgets/station_access/facility_tile.dart` | **P1** |
| 11 | `route_search_screen` SliverAppBar 리팩 | `screens/route_search_screen.dart` | **P1** |
| 12 | `station_access_screen` 필터+분리 스크롤 | `screens/station_access_screen.dart` | **P2** |

---

---

