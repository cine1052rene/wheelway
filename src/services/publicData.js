/** API 키를 보관하는 Firebase 서버 함수를 통해 시설 정보를 조회합니다. */
export async function getSeoulFacilities({ type = 'elevator', stationName = '' }) {
  const url = new URL('/api/facilities', window.location.origin);
  url.searchParams.set('type', type);
  if (stationName) url.searchParams.set('stnNm', stationName);
  const response = await fetch(url);
  if (!response.ok) throw new Error(`시설 정보 요청 실패 (${response.status})`);
  const body = await response.json();
  return body.rows ?? [];
}

/** 역별 실제 엘리베이터·에스컬레이터 위치(출구 번호, 상세 위치)를 한 번에 불러와 역명으로 묶습니다. */
export async function loadFacilityIndex() {
  const [elevators, escalators] = await Promise.all([
    getSeoulFacilities({ type: 'elevator' }),
    getSeoulFacilities({ type: 'escalator' })
  ]);
  const index = new Map();
  const push = (row, kind) => {
    if (!row.stnNm) return;
    const list = index.get(row.stnNm) ?? [];
    list.push({
      kind,
      exit: row.vcntEntrcNo || '',
      detail: row.dtlPstn || '',
      capacityKg: row.pscpWht || '',
      direction: row.upbdnbSe || ''
    });
    index.set(row.stnNm, list);
  };
  elevators.forEach(row => push(row, 'elevator'));
  escalators.forEach(row => push(row, 'escalator'));
  return index;
}

/** 하차역 기준으로 계단·엘리베이터 등 이동설비와 가장 가까운 열차 칸(출입문) 번호를 조회합니다. */
export async function getQuickExit(stationName) {
  const url = new URL('/api/quickExit', window.location.origin);
  url.searchParams.set('stnNm', stationName);
  const response = await fetch(url);
  if (!response.ok) throw new Error(`빠른하차 정보 요청 실패 (${response.status})`);
  const body = await response.json();
  return body.rows ?? [];
}

export const dataSources = [
  { name: '서울교통공사 편의시설 위치정보', detail: '엘리베이터·에스컬레이터 위치 및 운영 상태, 5분 단위 갱신', url: 'https://www.data.go.kr/data/15143841/openapi.do' },
  { name: '국가철도공단 역사별 엘리베이터 현황', detail: '엘리베이터 위치·정원·운행층·제원', url: 'https://www.data.go.kr/data/15041682/openapi.do' },
  { name: '서울교통공사 빠른하차정보', detail: '하차역 기준 이동설비와 가장 가까운 열차 칸·출입문 번호. 경로 결과 화면에서 도착역 기준으로 자동 조회됩니다.', url: 'https://www.data.go.kr/data/15143840/openapi.do' }
];
