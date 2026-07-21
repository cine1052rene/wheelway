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

## 실제 서비스 전환

1. 서울교통공사 `getFcElvtr`, `getFcEsctr` API와 국가철도공단 역사별 엘리베이터 제원을 서버에서 수집합니다.
2. 수집 결과를 `stations`, `facilities`, `facility_status`, `admin_notices` 테이블/컬렉션에 정규화합니다.
3. API 키와 관리자 권한은 브라우저에 넣지 않고, 서버리스 API와 인증을 사용합니다.
4. 네트워크를 수도권 전체 역·환승 통로 그래프로 확장하고 공사·고장 상태를 간선/시설 제약으로 반영합니다.

공공 데이터 출처는 앱의 **데이터 정보** 화면에서 바로 확인할 수 있습니다.

## Firebase 배포 전 설정

공개 배포 시 API 키를 앱에 넣지 않습니다. Firebase CLI에서 아래 한 번만 실행하세요.

```bash
firebase functions:secrets:set SEOUL_OPEN_DATA_KEY
firebase deploy --only functions,hosting
```

첫 명령에서 서울 열린데이터광장 API 키를 입력하면 Firebase Secret에만 저장됩니다. 이후 앱은 `/api/facilities` 서버 함수를 호출하므로 키가 브라우저나 배포된 JavaScript 파일에 노출되지 않습니다.
