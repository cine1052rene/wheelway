const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');

const seoulOpenDataKey = defineSecret('SEOUL_OPEN_DATA_KEY');
const seoulFastExitKey = defineSecret('SEOUL_FAST_EXIT_KEY');
const PAGE_SIZE = 1000;
const MAX_ROWS = 3000; // 서울 전역 엘리베이터/에스컬레이터 총량을 넉넉히 덮는 상한

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

function filterByStation(rows, stationName) {
  if (!stationName) return rows;
  const exact = rows.filter(row => row.stnNm === stationName);
  return exact.length ? exact : rows.filter(row => row.stnNm?.includes(stationName));
}

exports.facilities = onRequest(
  { region: 'asia-northeast3', secrets: [seoulOpenDataKey] },
  async (request, response) => {
    if (request.method !== 'GET') return response.status(405).json({ error: 'Method not allowed' });

    const type = request.query.type === 'escalator' ? 'escalator' : 'elevator';
    const service = type === 'elevator' ? 'getFcElvtr' : 'getFcEsctr';
    const stationName = typeof request.query.stnNm === 'string' ? request.query.stnNm.trim() : '';
    const key = seoulOpenDataKey.value();

    try {
      // 역명 경로/쿼리 필터가 상위 API에서 안정적으로 동작하지 않아, 전체를 페이지네이션으로 받아 서버에서 직접 필터링한다.
      let { rows, totalCount } = await fetchPage(service, key, 1, PAGE_SIZE);
      while (rows.length < Math.min(totalCount, MAX_ROWS)) {
        const start = rows.length + 1;
        const end = Math.min(rows.length + PAGE_SIZE, MAX_ROWS);
        const page = await fetchPage(service, key, start, end);
        if (page.rows.length === 0) break;
        rows = rows.concat(page.rows);
      }
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
      const rows = Array.isArray(items) ? items : items ? [items] : [];
      const resultCode = data.response?.header?.resultCode;
      const isErrorCode = resultCode !== undefined && resultCode !== null && !['00', '0', 0].includes(resultCode);
      if (isErrorCode && rows.length === 0) {
        console.error('Fast exit non-normal result:', resultCode, data.response?.header?.resultMsg);
        return response.status(502).json({ error: '공공데이터 인증 또는 서비스 설정을 확인하세요.' });
      }
      return response.json({ rows });
    } catch (error) {
      console.error('Fast exit request error:', error.message);
      return response.status(503).json({ error: '빠른하차 정보를 불러오지 못했습니다.' });
    }
  }
);
