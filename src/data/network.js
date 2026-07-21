export const stations = [
  { id: 'gangnam', name: '강남', lines: ['2'], elevator: true, escalator: true, capacityKg: 1600, doorWidthCm: 110, note: '10번 출구 방면 엘리베이터 이용' },
  { id: 'gyodae', name: '교대', lines: ['2', '3'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '2·3호선 환승 엘리베이터는 대합실 중앙에 있습니다.' },
  { id: 'sadang', name: '사당', lines: ['2', '4'], elevator: true, escalator: true, capacityKg: 1600, doorWidthCm: 110, note: '2↔4호선 환승 시 엘리베이터 2회 이용' },
  { id: 'isu', name: '이수', lines: ['4', '7'], elevator: true, escalator: true, capacityKg: 1000, doorWidthCm: 90, note: '4·7호선 환승 동선이 길어 여유 시간을 확보하세요.' },
  { id: 'dongjak', name: '동작', lines: ['4', '9'], elevator: true, escalator: true, capacityKg: 1000, doorWidthCm: 90, note: '현충원 방향 이동 시 승강장 엘리베이터 이용' },
  { id: 'ichon', name: '이촌', lines: ['4', '경의중앙'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '환승 통로의 경사가 있어 보조자 동행을 권장합니다.' },
  { id: 'seoul', name: '서울역', lines: ['1', '4', '공항', '경의중앙'], elevator: true, escalator: true, capacityKg: 1600, doorWidthCm: 110, note: '4호선↔1호선 환승은 엘리베이터 2회, 약 12분 소요' },
  { id: 'cityhall', name: '시청', lines: ['1', '2'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '1·2호선 환승은 엘리베이터 이용 가능' },
  { id: 'jonggak', name: '종각', lines: ['1'], elevator: true, escalator: true, capacityKg: 1000, doorWidthCm: 90, note: '1번 출구 방면 외부 엘리베이터' },
  { id: 'jongno3', name: '종로3가', lines: ['1', '3', '5'], elevator: true, escalator: true, capacityKg: 1000, doorWidthCm: 90, note: '1↔3·5호선 환승은 엘리베이터 동선이 복잡합니다.' },
  { id: 'euljiro3', name: '을지로3가', lines: ['2', '3'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '2·3호선 환승 엘리베이터 이용 가능' },
  { id: 'chungmuro', name: '충무로', lines: ['3', '4'], elevator: true, escalator: true, capacityKg: 1600, doorWidthCm: 110, note: '3·4호선 환승 엘리베이터 이용 가능' },
  { id: 'ddp', name: '동대문역사문화공원', lines: ['2', '4', '5'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '환승 이동거리 약 300m' },
  { id: 'yeouido', name: '여의도', lines: ['5', '9'], elevator: true, escalator: true, capacityKg: 1600, doorWidthCm: 110, note: '국회의사당 방면 출구 엘리베이터 운영' },
  { id: 'gongdeok', name: '공덕', lines: ['5', '6', '공항', '경의중앙'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '환승 엘리베이터를 따라 색상 표지를 확인하세요.' },
  { id: 'itaewon', name: '이태원', lines: ['6'], elevator: true, escalator: true, capacityKg: 1000, doorWidthCm: 90, note: '1번 출구 방면 엘리베이터' },
  { id: 'nowon', name: '노원', lines: ['4', '7'], elevator: true, escalator: true, capacityKg: 1350, doorWidthCm: 100, note: '4·7호선 환승 엘리베이터 이용 가능' },
  { id: 'sangbong', name: '상봉', lines: ['7', '경의중앙', '경춘'], elevator: true, escalator: true, capacityKg: 1600, doorWidthCm: 110, note: 'ITX·경춘선 방향은 별도 개찰구를 이용하세요.' },
  { id: 'demo_no_access', name: '접근성 확인 필요역', lines: ['X'], elevator: false, escalator: false, capacityKg: 0, doorWidthCm: 0, note: '등록된 장애인 편의시설이 없습니다. 다른 역을 이용하세요.', noFacility: true }
];

export const connections = [
  ['gangnam', 'gyodae', '2', 3], ['gyodae', 'sadang', '2', 4], ['gyodae', 'euljiro3', '3', 11],
  ['sadang', 'isu', '4', 3], ['isu', 'dongjak', '4', 4], ['dongjak', 'ichon', '4', 3], ['ichon', 'seoul', '4', 7],
  ['seoul', 'cityhall', '1', 2], ['cityhall', 'jonggak', '1', 2], ['jonggak', 'jongno3', '1', 2],
  ['euljiro3', 'jongno3', '3', 3], ['euljiro3', 'chungmuro', '3', 2], ['chungmuro', 'ddp', '4', 2],
  ['ddp', 'jongno3', '5', 3], ['ddp', 'nowon', '4', 22], ['nowon', 'sangbong', '7', 10],
  ['yeouido', 'gongdeok', '5', 5], ['gongdeok', 'jongno3', '5', 8], ['gongdeok', 'itaewon', '6', 10],
  ['gongdeok', 'seoul', '공항', 5], ['sangbong', 'ichon', '경의중앙', 20]
];

export const lineColors = { '1': '#3155a6', '2': '#00a84d', '3': '#ef7c1c', '4': '#00a5de', '5': '#984ea3', '6': '#b5500b', '7': '#697215', '9': '#b59600', '공항': '#0090d2', '경의중앙': '#77c4a3', '경춘': '#0c8e72', 'X': '#79847f' };
