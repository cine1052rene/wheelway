const { onRequest } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const seoulOpenDataKey = defineSecret('SEOUL_OPEN_DATA_KEY');
const seoulFastExitKey = defineSecret('SEOUL_FAST_EXIT_KEY');
const PAGE_SIZE = 1000;
const MAX_ROWS = 3000; // 서울 전역 엘리베이터/에스컬레이터 총량을 넉넉히 덮는 상한

// 서울 열린데이터광장 인증키는 계정당 일일 호출 한도가 있고, 매 요청마다
// 전체 데이터(최대 3000건, 3페이지)를 새로 긁어오면 응답도 느리고(약 11초)
// 실사용자 트래픽이 늘수록 한도 소진 위험도 커진다. 그래서 하루 두 번
// [refreshFacilitiesCache]가 미리 받아 역별로 Firestore에 저장해두고,
// [facilities] 요청은 원칙적으로 이 캐시만 읽는다. 캐시가 아직 한 번도
// 갱신되지 않은 경우(최초 배포 직후)에만 예전처럼 라이브로 조회한다.
const FACILITY_TYPES = [
  { type: 'elevator', service: 'getFcElvtr', collection: 'facilitiesCache_elevator' },
  { type: 'escalator', service: 'getFcEsctr', collection: 'facilitiesCache_escalator' },
];

async function fetchPage(service, key, start, end) {
  const url = new URL(`http://openapi.seoul.go.kr:8088/${key}/json/${service}/${start}/${end}/`);
  const upstream = await fetch(url);
  if (!upstream.ok) {
    const error = new Error(`upstream status ${upstream.status}`);
    error.upstreamStatus = upstream.status;
    throw error;
  }
  const raw = await upstream.text();
  let data;
  try {
    data = JSON.parse(raw);
  } catch {
    const error = new Error('non-json response');
    error.raw = raw;
    throw error;
  }
  const resultCode = data.response?.header?.resultCode;
  if (resultCode && resultCode !== '00') {
    const error = new Error('non-normal result');
    error.resultCode = resultCode;
    error.resultMsg = data.response?.header?.resultMsg;
    throw error;
  }
  const items = data.response?.body?.items?.item ?? [];
  const rows = Array.isArray(items) ? items : items ? [items] : [];
  const totalCount = Number(data.response?.body?.totalCount ?? rows.length);
  return { rows, totalCount };
}

// 첫 페이지로 totalCount를 안 뒤, 나머지 페이지는 순차가 아니라 병렬로 받는다
// (라이브 폴백 시 응답시간을 페이지 수만큼 줄이기 위함).
async function fetchAllRows(service, key) {
  const first = await fetchPage(service, key, 1, PAGE_SIZE);
  const total = Math.min(first.totalCount, MAX_ROWS);
  const tasks = [];
  for (let start = PAGE_SIZE + 1; start <= total; start += PAGE_SIZE) {
    const end = Math.min(start + PAGE_SIZE - 1, total);
    tasks.push(fetchPage(service, key, start, end));
  }
  const pages = await Promise.all(tasks);
  let rows = first.rows;
  for (const page of pages) rows = rows.concat(page.rows);
  return rows;
}

function filterByStation(rows, stationName) {
  if (!stationName) return rows;
  const exact = rows.filter(row => row.stnNm === stationName);
  return exact.length ? exact : rows.filter(row => row.stnNm?.includes(stationName));
}

// Firestore 문서ID는 '/'를 쓸 수 없고 너무 길면 안 되니 안전하게 치환.
function stationDocId(stnNm) {
  return (stnNm || '(unknown)').replace(/\//g, '_').slice(0, 300);
}

async function refreshOneType({ service, collection }, key) {
  const rows = await fetchAllRows(service, key);
  const byStation = new Map();
  for (const row of rows) {
    const docId = stationDocId(row.stnNm);
    if (!byStation.has(docId)) byStation.set(docId, []);
    byStation.get(docId).push(row);
  }

  const entries = [...byStation.entries()];
  const BATCH_SIZE = 400; // Firestore 배치 쓰기 한도(500) 아래로 여유있게
  for (let i = 0; i < entries.length; i += BATCH_SIZE) {
    const batch = db.batch();
    for (const [docId, stationRows] of entries.slice(i, i + BATCH_SIZE)) {
      batch.set(db.collection(collection).doc(docId), {
        rows: stationRows,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  await db.collection('facilitiesIndex').doc(collection).set({
    keys: entries.map(([docId]) => docId),
    updatedAt: FieldValue.serverTimestamp(),
    totalRows: rows.length,
  });

  return { stationCount: entries.length, totalRows: rows.length };
}

// 캐시에서 역 이름으로 조회. 반환값 의미:
//  - 배열: 캐시 적중(빈 배열이면 "이 역엔 해당 설비가 없다"는 뜻, 원본 데이터 기준 정상)
//  - null: 캐시가 아직 한 번도 갱신되지 않음 → 호출부에서 라이브 폴백 필요
async function readFromCache(facilityType, stationName) {
  const exactDoc = await db.collection(facilityType.collection).doc(stationDocId(stationName)).get();
  if (exactDoc.exists) return exactDoc.data().rows ?? [];

  const indexDoc = await db.collection('facilitiesIndex').doc(facilityType.collection).get();
  if (!indexDoc.exists) return null;

  const keys = indexDoc.data().keys || [];
  const matched = keys.filter(k => k.includes(stationName));
  if (matched.length === 0) return [];

  const docs = await Promise.all(matched.map(k => db.collection(facilityType.collection).doc(k).get()));
  return docs.filter(d => d.exists).flatMap(d => d.data().rows ?? []);
}

exports.facilities = onRequest(
  { region: 'asia-northeast3', secrets: [seoulOpenDataKey] },
  async (request, response) => {
    if (request.method !== 'GET') return response.status(405).json({ error: 'Method not allowed' });

    const type = request.query.type === 'escalator' ? 'escalator' : 'elevator';
    const facilityType = FACILITY_TYPES.find(f => f.type === type);
    const stationName = typeof request.query.stnNm === 'string' ? request.query.stnNm.trim() : '';

    try {
      if (stationName) {
        const cached = await readFromCache(facilityType, stationName);
        if (cached !== null) return response.json({ rows: cached });
      }

      // 캐시 미스(최초 배포 직후, 아직 한 번도 갱신 전) 또는 stnNm 없이
      // 전체 조회하는 드문 경우에만 예전처럼 라이브로 받아온다.
      const key = seoulOpenDataKey.value();
      const rows = await fetchAllRows(facilityType.service, key);
      return response.json({ rows: filterByStation(rows, stationName) });
    } catch (error) {
      if (error.raw !== undefined) {
        console.error('Seoul Open Data returned non-JSON response:', error.raw.slice(0, 300));
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      if (error.resultCode) {
        console.error('Seoul Open Data non-normal result:', error.resultCode, error.resultMsg);
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      console.error('Seoul Open Data request error:', error.message);
      return response.status(503).json({ error: '시설 정보를 불러오지 못했습니다.' });
    }
  }
);

// 하루 두 번(00시/12시, 서울시각) 엘리베이터·에스컬레이터 전체 데이터를 받아
// 역별로 Firestore에 캐싱한다. [facilities] 요청은 이 캐시를 우선 사용한다.
exports.refreshFacilitiesCache = onSchedule(
  {
    schedule: 'every 12 hours',
    timeZone: 'Asia/Seoul',
    region: 'asia-northeast3',
    secrets: [seoulOpenDataKey],
    timeoutSeconds: 300,
    memory: '256MiB',
  },
  async () => {
    const key = seoulOpenDataKey.value();
    for (const facilityType of FACILITY_TYPES) {
      const result = await refreshOneType(facilityType, key);
      console.log(
        `Refreshed ${facilityType.type} cache: ${result.stationCount} stations, ${result.totalRows} rows`
      );
    }
  }
);

// 배포 직후나 데이터 갱신이 급할 때 12시간 스케줄을 기다리지 않고 즉시
// 캐시를 채우기 위한 수동 트리거. 공개 데이터라 노출 위험은 낮지만,
// 무의미한 외부 API 남용을 막기 위해 최소한의 토큰 확인만 둔다.
exports.refreshFacilitiesNow = onRequest(
  { region: 'asia-northeast3', secrets: [seoulOpenDataKey], timeoutSeconds: 300, memory: '256MiB' },
  async (request, response) => {
    if (request.query.token !== 'wheelway-manual-refresh') {
      return response.status(403).json({ error: 'forbidden' });
    }
    const key = seoulOpenDataKey.value();
    const results = {};
    for (const facilityType of FACILITY_TYPES) {
      results[facilityType.type] = await refreshOneType(facilityType, key);
    }
    return response.json({ ok: true, results });
  }
);

// 서울교통공사_빠른하차정보 (data.go.kr, B553766/inout/getFstExit)
// 하차역 기준으로 계단·엘리베이터 등 이동설비와 가장 가까운 열차 칸(출입문) 번호를 제공한다.
exports.quickExit = onRequest(
  { region: 'asia-northeast3', secrets: [seoulFastExitKey] },
  async (request, response) => {
    if (request.method !== 'GET') return response.status(405).json({ error: 'Method not allowed' });

    const stationName = typeof request.query.stnNm === 'string' ? request.query.stnNm.trim() : '';
    if (!stationName) return response.status(400).json({ error: '역명(stnNm)을 입력하세요.' });

    const url = new URL('https://apis.data.go.kr/B553766/inout/getFstExit');
    url.searchParams.set('serviceKey', seoulFastExitKey.value());
    url.searchParams.set('dataType', 'JSON');
    url.searchParams.set('numOfRows', '200');
    url.searchParams.set('pageNo', '1');
    url.searchParams.set('stnNm', stationName);

    try {
      const upstream = await fetch(url);
      if (!upstream.ok) {
        console.error('Fast exit response status:', upstream.status);
        return response.status(502).json({ error: '공공데이터 서버 응답 오류' });
      }
      const raw = await upstream.text();
      let data;
      try {
        data = JSON.parse(raw);
      } catch {
        console.error('Fast exit returned non-JSON response:', raw.slice(0, 300));
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      // Swagger 예시 문서는 {header,body} 최상위 구조로 보이지만, 실제 응답은 {response:{header,body}}로 감싸져 온다.
      const items = data.response?.body?.items?.item;
      let rows = Array.isArray(items) ? items : items ? [items] : [];
      const resultCode = data.response?.header?.resultCode;
      const isErrorCode = resultCode !== undefined && resultCode !== null && !['00', '0', 0].includes(resultCode);
      if (isErrorCode && rows.length === 0) {
        console.error('Fast exit non-normal result:', resultCode, data.response?.header?.resultMsg);
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      // 환승역(같은 역명을 여러 노선이 공유)은 이 API가 노선 구분 없이 전체를
      // 섞어서 돌려준다 — 그대로 쓰면 "5호선 승차" 화면에 2호선 칸번호가
      // 섞여 나오는 오류가 생긴다(실사용자 피드백으로 발견). lineNm이 오면
      // 그 노선 것만 남긴다.
      const lineNm = typeof request.query.lineNm === 'string' ? request.query.lineNm.trim() : '';
      if (lineNm) rows = rows.filter(row => row.lineNm === lineNm);
      return response.json({ rows });
    } catch (error) {
      console.error('Fast exit request error:', error.message);
      return response.status(503).json({ error: '빠른하차 정보를 불러오지 못했습니다.' });
    }
  }
);

// 서울시 지하철 실시간 도착정보 (data.seoul.go.kr, swopenAPI 서브웨이 실시간)
// 서울 열린데이터광장 인증키는 데이터셋별이 아니라 계정 공통 키라, 기존
// facilities에서 쓰던 seoulOpenDataKey를 그대로 재사용한다(별도 키 발급 불필요).
exports.arrivals = onRequest(
  { region: 'asia-northeast3', secrets: [seoulOpenDataKey] },
  async (request, response) => {
    if (request.method !== 'GET') return response.status(405).json({ error: 'Method not allowed' });

    const stationName = typeof request.query.stnNm === 'string' ? request.query.stnNm.trim() : '';
    if (!stationName) return response.status(400).json({ error: '역명(stnNm)을 입력하세요.' });

    const key = seoulOpenDataKey.value();
    // 이 API만 도메인이 다르다(openapi.seoul.go.kr:8088이 아니라 swopenapi.seoul.go.kr) —
    // 같은 서울 열린데이터광장 계정 인증키를 그대로 쓰지만 엔드포인트가 분리돼 있음.
    const url = `http://swopenapi.seoul.go.kr/api/subway/${key}/json/realtimeStationArrival/0/20/${encodeURIComponent(stationName)}`;

    try {
      const upstream = await fetch(url);
      if (!upstream.ok) {
        console.error('Realtime arrival response status:', upstream.status);
        return response.status(502).json({ error: '공공데이터 서버 응답 오류' });
      }
      const raw = await upstream.text();
      let data;
      try {
        data = JSON.parse(raw);
      } catch {
        console.error('Realtime arrival returned non-JSON response:', raw.slice(0, 300));
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      const status = data.errorMessage?.status ?? data.status;
      // INFO-200(정상, 데이터 없음)은 에러가 아니라 "지금 도착 예정 열차가 없다"는 뜻.
      if (status !== undefined && status !== 200 && data.errorMessage?.code !== 'INFO-200') {
        console.error('Realtime arrival non-normal result:', status, data.errorMessage?.message);
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      const rows = Array.isArray(data.realtimeArrivalList) ? data.realtimeArrivalList : [];
      return response.json({ rows });
    } catch (error) {
      console.error('Realtime arrival request error:', error.message);
      return response.status(503).json({ error: '실시간 도착정보를 불러오지 못했습니다.' });
    }
  }
);
