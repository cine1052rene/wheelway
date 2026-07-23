# WheelWay

휠체어·목발 이용자를 위한 서울·수도권 지하철 접근성 길찾기 PWA 프로토타입입니다.

## 실행

```bash
npm install
npm run dev
```

## 핵심 동작

- 목발: 엘리베이터 또는 에스컬레이터 경로
- 수동 휠체어: 엘리베이터 경로만 사용
- 전동 휠체어: 1,000kg 이상, 문폭 90cm 이상 엘리베이터만 사용
- 편의시설 미등록 역은 추천 경로에서 제외
- 관리자 화면에서 설비 상태 및 주의 공지를 변경 (현재는 브라우저 로컬 저장)

## 네트워크 데이터 (`src/data/`)

- `stations.js`/`connections.js`는 `scripts/build_network.py`가 서울교통공사 공개데이터(엘리베이터·에스컬레이터 현황)로 **자동 생성**합니다. 데이터가 갱신되면 `elev.json`/`escal.json`(라이브 API 응답)을 받아 스크립트를 다시 실행하면 됩니다.
- 대상 범위: **1~8호선**(서울교통공사 관할) 중 편의시설 데이터가 확인된 역 240개. 9호선·공항철도·신분당선·수인분당선 등 타 운영사 노선은 아직 미포함.
- `capacityKg`(엘리베이터 정격하중)는 실측값입니다. `doorWidthCm`은 이 공공데이터에 문 폭 필드 자체가 없어 **법정 최소 기준(90cm) 추정치**이며, `doorWidthEstimated:true`로 표시됩니다 — 실측값이 아님을 UI에도 노출합니다.
- 역간 소요시간(분)은 실측 시간표가 아니라 평균 역간 운행시간(약 2분) 기준 추정치입니다.
- 자세한 산정 방식은 `scripts/build_network.py` 상단 주석을 참고하세요.

## 실제 서비스 전환

1. ~~서울교통공사 `getFcElvtr`, `getFcEsctr` API 기반 네트워크 자동 생성~~ → 완료 (1~8호선, 위 참고). 국가철도공단 역사별 엘리베이터 제원(문 폭 등 추가 필드) 연동은 남은 과제.
2. 수집 결과를 정식 백엔드(`facilities`, `facility_status`, `admin_notices`)로 옮기고 실시간 갱신을 붙입니다.
3. API 키와 관리자 권한은 브라우저에 넣지 않고, 서버리스 API와 인증을 사용합니다.
4. 9호선·공항철도 등 잔여 노선을 추가하고, 공사·고장 상태를 간선/시설 제약으로 실시간 반영합니다.

공공 데이터 출처는 앱의 **데이터 정보** 화면에서 바로 확인할 수 있습니다.

## Firebase 배포 전 설정

공개 배포 시 API 키를 앱에 넣지 않습니다. Firebase CLI에서 아래 한 번만 실행하세요.

```bash
firebase functions:secrets:set SEOUL_OPEN_DATA_KEY
firebase deploy --only functions,hosting
```

첫 명령에서 서울 열린데이터광장 API 키를 입력하면 Firebase Secret에만 저장됩니다. 이후 앱은 `/api/facilities` 서버 함수를 호출하므로 키가 브라우저나 배포된 JavaScript 파일에 노출되지 않습니다.
