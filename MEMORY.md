# WheelWay 작업 메모

- 2026-07-22: 서울·수도권 지하철 접근성 길찾기 PWA 프로토타입을 새로 구성했다.
- 이용자 유형별 제약: 목발(엘리베이터/에스컬레이터), 수동 휠체어(엘리베이터), 전동 휠체어(1,000kg 이상·문폭 90cm 이상)를 경로 엔진에 반영했다.
- 서울교통공사 편의시설 API와 국가철도공단 엘리베이터 현황을 데이터 소스로 연결할 어댑터를 만들었다. 운영 시 API 키는 서버리스 프록시에서 처리해야 한다.
- 관리자의 시설 상태·주의 공지는 현재 프로토타입에서 localStorage에 저장된다. 실서비스 전환 시 인증 및 DB 연동이 필요하다.
- `node .\\node_modules\\vite\\bin\\vite.js build --debug` 빌드가 성공했다.
- 2026-07-22 (이어서, Claude/ttapp): Codex가 `firebase deploy --only functions:facilities` 승인 대기 중 사용량 한도로 멈춘 지점을 이어받아 배포 완료. 이후 `functions/index.js`의 실제 버그 2건을 발견·수정:
  1. 서울 열린데이터광장 응답 구조가 `{getFcElvtr:{row:[...]}}`가 아니라 `{response:{header,body:{items:{item:[...]}}}}` 형태였는데 옛 파싱 코드가 `data[service].row`를 읽어 항상 빈 배열을 반환했다. → `data.response.body.items.item` 파싱 + `resultCode !== '00'` 오류 처리로 수정.
  2. `stnNm` 역명 필터가 상위 API에서 쿼리스트링/경로 세그먼트 모두 안정적으로 동작하지 않아, 전체 데이터를 페이지네이션(최대 3000건, 1000건 단위)으로 받아 서버 함수 내부에서 완전일치 우선 필터링하도록 변경.
- `https://emeraldworks.web.app/api/facilities?stnNm=강남` 실호출로 엘리베이터 4건 정상 확인 완료. API 키(`SEOUL_OPEN_DATA_KEY`)는 Firebase Secret에 정상 반영되어 있다(버전 2).
- 다음에 이어서 할 것: 프론트엔드는 아직 하드코딩된 19개 역 목데이터(`src/data/network.js`)를 사용 중 — 실제 서비스 전환 시 이 API 응답을 stations/facilities 데이터로 정규화해 반영해야 한다(README "실제 서비스 전환" 절 참고).
- 2026-07-22 (사용자 피드백 반영): "칸번호도 안내 안 해주면서 무슨 지름길이냐"는 지적을 받고 점검한 결과, 지금까지 연결한 공공데이터가 실제 경로 안내(`routeEngine.js`)에는 전혀 반영되지 않고 "데이터 정보" 탭의 연결 확인용으로만 쓰이고 있었다는 걸 확인했다.
  - 1차 개선(배포 완료): "역 접근성" 탭에 실제 엘리베이터/에스컬레이터의 출구 번호(`vcntEntrcNo`)·상세 위치(`dtlPstn`)를 보여주는 "실제 위치 정보 불러오기" 기능을 추가했다 (`publicData.js`의 `loadFacilityIndex()`, `main.js`의 `facilityListHtml`).
  - 진짜 필요한 기능(칸번호 안내)은 **서울교통공사_빠른하차정보 API**(data.go.kr, ID 15143840 — 하차역 기준 이동설비와 가장 가까운 열차 칸/출입문 번호 제공)로 해결 가능함을 확인. 단 이건 기존 서울 열린데이터광장 키(`openapi.seoul.go.kr`)와 별개로 data.go.kr(`apis.data.go.kr` 게이트웨이) 활용신청과 인증키가 별도로 필요하며, 로그인 없이는 정확한 요청/응답 스펙(Swagger)도 확인 불가 — **사용자가 직접 data.go.kr에서 활용신청 후 인증키를 전달해야 진행 가능** (사용자 액션 대기 중).
  - 데이터 정보 탭의 `dataSources`에 이 API를 "연동 예정"으로 표시해 현재 한계를 투명하게 공개했다.
- 2026-07-22 (칸번호 안내 완성): 사용자가 data.go.kr에서 활용신청 후 인증키를 전달 → Playwright로 로그인 없이 볼 수 없던 Swagger 페이지를 직접 렌더링해 실제 스펙을 확인했다.
  - **Base URL**: `apis.data.go.kr/B553766/inout`, 엔드포인트 `GET /getFstExit` (serviceKey, stnNm, dataType=JSON 등 파라미터). 응답도 기존 API와 동일하게 문서상 예시(`{header,body}`)와 달리 실제로는 `{response:{header,body:{items:{item:[...]}}}}`로 감싸져 온다는 걸 실호출로 재확인.
  - 핵심 필드: `qckgffVhclDoorNo`(칸-문 번호, 예: "8-1"), `plfmCmgFac`(인접 시설, "엘리베이터"/"계단" 등), `upbdnbSe`(상행/하행), `drtnInfo`(방면), `fwkPstnNm`(역사 내 위치).
  - 인증키는 `SEOUL_FAST_EXIT_KEY` Firebase Secret으로 저장. 새 함수 `functions/index.js`의 `quickExit` (라우트: `/api/quickExit?stnNm=역명`) 추가, `firebase.json`에 rewrite 추가.
  - 프론트: `publicData.js`의 `getQuickExit()`, `main.js`의 `findRoute()`(경로탐색 시 도착역 기준 자동 조회)와 `quickExitHtml()`(결과 화면에 "🚪 도착역 엘리베이터와 가장 가까운 칸" 카드로 상행/하행별 칸번호 노출)로 완전히 연동해 배포 완료.
  - 실제 라이브 확인: `https://emeraldworks.web.app/api/quickExit?stnNm=강남` → 16건, 서울역 → 28건 정상 응답.
  - 남은 한계: 사용자의 실제 진행 방향(상행/하행)을 앱이 자동 판별하지 않고 후보를 다 보여주므로 사용자가 방면 텍스트를 보고 스스로 골라야 한다. 추후 `routeEngine.js`의 경로 방향 정보와 매칭해 자동으로 한 줄만 추천하도록 개선 여지 있음.
- 2026-07-22 (내비게이션 UX 전면 재구성): "배치가 보고서 같다. 지상 진입→승강장→승차 칸→환승/하차 방향까지 실제 이동 순서로 알려줘야 지름길 내비게이션"이라는 피드백을 받고, 카드 나열식 결과 화면을 실제 이동 스텝 타임라인으로 갈아엎었다.
  - 새 모듈 `src/services/journey.js`: `buildJourney(originName, destName, legs)` — 경로의 각 구간을 '지상 진입 → 승차 칸 → 환승/하차 → 지상 이동' 순서로 확장하고, 필요한 실제 데이터(엘리베이터, 칸번호)를 병렬로 fetch. 엘리베이터는 `bgngFlrGrndUdgdSe`/`endFlrGrndUdgdSe` 필드로 '지상↔지하 진입용'과 '역 구내(환승) 이동용'을 구분해 분리했다.
  - `main.js`: `journeyHtml()`이 🚶진입→🚇승차(칸번호 후보)→🔀환승(구내 엘리베이터+메모)→🚇승차→🚪도착(지상 엘리베이터) 순서의 세로 타임라인을 렌더링. 기존 `quickExitHtml`/`access-note`/`steps` 요약 블록은 전부 이 타임라인으로 대체.
  - 실제 배포 후 Playwright로 라이브 검증 중 버그 2건 발견·즉시 수정: (1) 환승 메모를 `<ul>` 닫힌 뒤에 `<li>`로 이어붙여 HTML이 깨져 타임라인 밖으로 새어나가던 문제 → `<p class="journey-note">`로 변경, (2) "서울역" 같이 이미 '역'으로 끝나는 역명에 '역'이 중복 표시되던 문제("서울역역") → `stationLabel()` 헬퍼로 수정.
  - 최종 확인: 강남→서울역 검색 시 실제 화면에 강남역 1/10번 출구 엘리베이터 → 2호선 승차 칸 후보 3건 → 사당역 환승 엘리베이터+메모 → 4호선 승차 칸 후보 4건 → 서울역 2/3/4번 출구 엘리베이터까지 하나의 연결된 타임라인으로 정상 표시됨을 스크린샷으로 확인.
- 2026-07-22 (심각한 CSS 렌더링 버그 발견·수정): 사용자가 "지금 말한 것처럼 안 보인다"고 지적 → Playwright로 라이브 화면을 스크린샷+DOM 실측(`getClientRects()`)까지 해보니, `.journey-detail`/`.facility-list`(둘 다 `display:grid`, 명시적 컬럼 폭 없음) 안의 `<li>` 한글 텍스트가 박스는 정상 폭(367px)인데 실제 텍스트 줄은 ~20~30px 폭으로 쪼개져 세로로 다 무너져 있었다. `min-width:0`, `grid-template-columns:1fr` 둘 다 시도했지만 해결 안 됨 — CSS Grid의 고유 크기 계산이 한글(CJK) 텍스트의 "아무 데서나 줄바꿈 가능" 특성과 얽혀 생기는 브라우저 버그로 추정. **`display:grid`를 `display:flex;flex-direction:column`으로 교체**해서 완전히 해결(플렉스는 이 문제에서 자유로움). `.journey-steps`, `.journey-detail`, `.facility-list` 전부 flex로 전환.
  - 검증 방법을 강화: 이제부터 화면 확인은 스크린샷만 보지 않고 `document.createRange().getClientRects()`로 실제 렌더링된 텍스트 줄 폭을 직접 재서 확인한다 (스크린샷은 세로로 긴 이미지일 때 축소 왜곡으로 오판하기 쉬움).
- 2026-07-22 (역 접근성 카드 겹침 버그): 사용자가 "역 접근성 페이지 글씨가 겹쳐 보인다" 지적 → 확인해보니 `.status`(이용가능/우회 필요 칩)를 `float:right`+`margin-top:-21px`로 억지로 우측 상단에 띄우는 구식 CSS 트릭이 원인이었다. 노선 배지가 2개 이하인 역은 우연히 안 겹쳤지만, 서울역(4개 노선)·상봉(3개 노선)처럼 배지가 많아 헤더 줄이 길어지는 역은 역명(h3, `justify-content:space-between`으로 우측 정렬)과 상태 칩이 같은 우상단 자리를 두고 정면으로 겹쳤다.
  - 수정: `.station-card{position:relative}` + `.status{position:absolute;top:18px;right:18px}`로 안정적으로 고정 배치, `.station-card>div`는 `padding-right:72px`로 배지 공간을 항상 비워두고 `flex-wrap:wrap`을 추가해 배지가 많아도 줄바꿈되도록 함.
  - 검증: 19개 역 카드 전부 `h3`·`.status`의 `getBoundingClientRect()` 겹침 여부를 코드로 계산해 전부 `false`(겹침 없음) 확인 후 스크린샷으로 최종 확인.
