// network.js: stations.js/connections.js를 재노출하는 barrel 파일.
// 파일당 500라인 제한(CLAUDE.md)을 지키기 위해 실제 데이터는 두 파일로 분리했습니다.
export { stations } from './stations.js';
export { connections } from './connections.js';

// 노선별 공식 색상(서울교통공사 CI 기준). 데이터셋에 아직 없는 노선(9호선 등)도
// 추후 확장을 대비해 남겨둔다 — 사용되지 않는 키는 무해함.
export const lineColors = {
  '1': '#0d3692', '2': '#00a84d', '3': '#ef7c1c', '4': '#00a5de',
  '5': '#984ea3', '6': '#b5500b', '7': '#697215', '8': '#e6186c',
  '9': '#bb8336', '공항': '#0090d2', '경의중앙': '#77c4a3', '경춘': '#0c8e72', 'X': '#79847f'
};
