import './styles.css';
import { stations, lineColors } from './data/network.js';
import { getRoute } from './services/routeEngine.js';
import { dataSources, getSeoulFacilities, loadFacilityIndex } from './services/publicData.js';
import { buildJourney } from './services/journey.js';

const state = {
  profile: 'manual', from: '강남', to: '서울역', activeTab: 'route',
  overrides: JSON.parse(localStorage.getItem('wheelway-overrides') || '{}'),
  notices: JSON.parse(localStorage.getItem('wheelway-notices') || '[]'),
  result: null, syncing: false, syncMessage: '',
  facilityIndex: null, facilityLoading: false, facilityError: '',
  journey: null, journeyLoading: false, journeyError: ''
};

const app = document.querySelector('#app');
const escape = value => String(value).replace(/[&<>"']/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[char]));
const currentStation = id => ({ ...stations.find(station => station.id === id), ...(state.overrides[id] ?? {}) });

function render() {
  app.innerHTML = `
    <header class="topbar"><a class="brand" href="#" aria-label="WheelWay 홈"><span class="brand-mark">W</span><span>WheelWay</span></a><div class="live"><span></span>접근성 길찾기</div><button class="admin-link" data-action="admin">관리자</button></header>
    <main>
      <section class="hero">
        <div><p class="eyebrow">서울·수도권 지하철</p><h1>계단 없이,<br><em>나에게 맞는</em> 길로.</h1><p class="hero-copy">휠체어와 목발 이용자를 위해 엘리베이터 용량, 환승 동선, 공사 정보를 반영한 길찾기입니다.</p></div>
        <div class="hero-art" aria-hidden="true"><div class="orbit orbit-1"></div><div class="orbit orbit-2"></div><div class="wheel">♿</div><span class="star s1">✦</span><span class="star s2">✦</span></div>
      </section>
      <nav class="tabs" aria-label="서비스 메뉴"><button class="${state.activeTab === 'route' ? 'active' : ''}" data-tab="route">길찾기</button><button class="${state.activeTab === 'stations' ? 'active' : ''}" data-tab="stations">역 접근성</button><button class="${state.activeTab === 'sources' ? 'active' : ''}" data-tab="sources">데이터 정보</button></nav>
      ${state.activeTab === 'route' ? routeView() : state.activeTab === 'stations' ? stationsView() : sourcesView()}
    </main>
    <footer>WheelWay 베타 · 출발 전 운영기관의 실시간 안내를 한 번 더 확인하세요.</footer>
    <dialog id="admin-dialog">${adminView()}</dialog>
  `;
  bindEvents();
}

function routeView() {
  const result = state.result;
  return `<section class="route-layout"><div class="search-card">
    <div class="section-title"><span class="icon-chip">⌖</span><div><h2>이동 조건</h2><p>이용 유형에 따라 안전한 동선만 추천해요.</p></div></div>
    <fieldset class="profiles"><legend>이용 유형</legend>
      ${profileButton('crutch', '🩼', '목발', '에스컬레이터 또는 엘리베이터')}${profileButton('manual', '♿', '수동 휠체어', '엘리베이터만')}${profileButton('electric', '🛵', '전동 휠체어', '대형·고중량 엘리베이터만')}
    </fieldset>
    <div class="station-fields"><label>출발역<select id="from">${stationOptions(state.from)}</select></label><div class="route-line"><span></span><span></span><span></span></div><label>도착역<select id="to">${stationOptions(state.to)}</select></label></div>
    <button class="find-button" data-action="find-route">안전한 경로 찾기 <span>→</span></button>
  </div>
  <div class="result-area">${result ? resultView(result) : emptyRouteView()}</div></section>`;
}

function profileButton(id, icon, title, desc) { return `<button class="profile ${state.profile === id ? 'selected' : ''}" data-profile="${id}"><span class="profile-icon">${icon}</span><strong>${title}</strong><small>${desc}</small></button>`; }
function stationOptions(selected) { return stations.map(station => `<option value="${station.id}" ${station.id === selected ? 'selected' : ''}>${station.name}${station.noFacility ? ' · 편의시설 없음' : ''}</option>`).join(''); }

function emptyRouteView() { return `<div class="empty-card"><div class="route-placeholder"><div></div><div></div><div></div><div></div></div><h2>이동 조건을 선택하세요</h2><p>엘리베이터 이용 가능 여부와 환승 동선을 고려해 최적 경로를 안내합니다.</p></div>`; }
function resultView(result) {
  if (result.error) return `<div class="alert-card danger"><span>!</span><div><h2>추천 경로 없음</h2><p>${escape(result.error)}</p><small>편의시설이 없는 역은 자동으로 피합니다.</small></div></div>`;
  return `<div class="route-result"><div class="result-top"><div><p class="eyebrow">${result.profileLabel} 기준 추천</p><h2>${currentStation(state.from).name} <span>→</span> ${currentStation(state.to).name}</h2></div><strong>${result.totalMinutes}<small>분</small></strong></div>
  <div class="route-summary"><span>엘리베이터 ${result.transferStations.length + 2}회</span><i></i><span>환승 ${result.transferStations.length}회</span><i></i><span>예상 ${result.totalMinutes}분</span></div>
  ${journeyHtml()}
  ${state.notices.length ? `<div class="notice-strip">⚠ ${escape(state.notices.at(-1).message)}</div>` : ''}</div>`;
}

/** 경로를 '지상 진입 → 승차 칸 → 환승/하차 → 지상 이동'의 실제 이동 순서 타임라인으로 그립니다. */
function journeyHtml() {
  if (state.journeyLoading) return `<div class="journey-card"><p>실제 이동 동선(엘리베이터·칸번호)을 불러오는 중...</p></div>`;
  if (state.journeyError) return `<div class="journey-card warn"><p>이동 동선 정보를 불러오지 못했습니다 · ${escape(state.journeyError)}</p></div>`;
  if (!state.journey) return '';
  const j = state.journey;
  const steps = [stepHtml('🚶', `${stationLabel(j.enter.station)} 진입 · 지상 → 지하`, elevatorDetail(j.enter.elevators))];
  j.legs.forEach(leg => {
    steps.push(stepHtml('🚇', `${leg.line}호선 승차 · ${escape(leg.fromName)} → ${escape(leg.toName)}`, carDetail(leg.cars), `${leg.minutes}분`));
    const note = leg.transferNote ? `<p class="journey-note">💡 ${escape(leg.transferNote)}</p>` : '';
    steps.push(leg.isTransfer
      ? stepHtml('🔀', `${stationLabel(leg.toName)} 환승`, elevatorDetail(leg.arrivalElevators) + note)
      : stepHtml('🚪', `${stationLabel(leg.toName)} 도착 · 지하 → 지상`, elevatorDetail(leg.arrivalElevators)));
  });
  return `<div class="journey"><h3 class="journey-title">🗺 실제 이동 동선</h3><ol class="journey-steps">${steps.join('')}</ol></div>`;
}

function stationLabel(name) { return name.endsWith('역') ? escape(name) : `${escape(name)}역`; }

function stepHtml(icon, title, bodyHtml, badge) {
  return `<li><span class="journey-icon">${icon}</span><div><b>${title}${badge ? `<em>${escape(badge)}</em>` : ''}</b>${bodyHtml}</div></li>`;
}

function elevatorDetail(entries) {
  if (!entries.length) return `<p class="journey-empty">실제 엘리베이터 데이터 없음 · 현장 안내 확인</p>`;
  const items = entries.slice(0, 3).map(entry => `<li>🛗 ${entry.exit ? escape(entry.exit) + ' 방면' : '내부'}${entry.detail ? ' · ' + escape(entry.detail) : ''}${entry.from && entry.to ? ` · ${escape(entry.from)}↔${escape(entry.to)}` : ''}</li>`).join('');
  return `<ul class="journey-detail">${items}</ul>`;
}

function carDetail(cars) {
  if (!cars.length) return `<p class="journey-empty">칸번호 데이터 없음 · 역무원 안내 확인</p>`;
  const items = cars.slice(0, 4).map(car => `<li>🚪 <b>${escape(car.door)}번째 칸</b>${car.direction ? ' · ' + escape(car.direction) : ''}${car.toward ? ' ' + escape(car.toward) + ' 방면' : ''} → 엘리베이터 최단</li>`).join('');
  return `<p class="journey-hint">진행 방향에 맞는 항목을 확인하세요</p><ul class="journey-detail">${items}</ul>`;
}

function facilityListHtml(stationName) {
  if (!state.facilityIndex) return '';
  const entries = state.facilityIndex.get(stationName) ?? [];
  if (!entries.length) return '<p class="facility-empty">이 역은 실제 시설 데이터가 아직 없습니다 · 아래 안내를 확인하세요</p>';
  const items = entries.slice(0, 4).map(entry => {
    const label = entry.kind === 'elevator' ? '🛗 엘리베이터' : '🪜 에스컬레이터';
    const exit = entry.exit ? `${entry.exit} 방면` : '내부';
    const extra = entry.kind === 'elevator' && entry.capacityKg ? ` · ${entry.capacityKg}kg` : entry.direction ? ` · ${entry.direction}` : '';
    return `<li>${label} · ${exit}${entry.detail ? ' · ' + escape(entry.detail) : ''}${extra}</li>`;
  }).join('');
  const more = entries.length > 4 ? `<li class="facility-more">그 외 ${entries.length - 4}건 더</li>` : '';
  return `<ul class="facility-list">${items}${more}</ul>`;
}

function stationsView() {
  return `<section class="station-page"><div class="page-heading"><p class="eyebrow">역별 접근성</p><h2>편의시설 현황</h2><p>관리자 공지와 공개 데이터를 함께 보여줍니다. '편의시설 없음' 역은 경로 추천에서 제외됩니다.</p>
    <div class="sync-actions"><button data-action="load-facilities" ${state.facilityLoading ? 'disabled' : ''}>${state.facilityLoading ? '불러오는 중...' : state.facilityIndex ? '실제 위치 정보 새로고침' : '실제 엘리베이터·에스컬레이터 위치 불러오기'}</button></div>
    ${state.facilityError ? `<p class="facility-error">${escape(state.facilityError)}</p>` : ''}
    ${state.facilityIndex ? '<p class="facility-caveat">⚠ 몇 번째 열차 칸을 타야 이 엘리베이터와 가장 가까운지는 아직 안내하지 않습니다 — 관련 공공데이터(서울교통공사 빠른하차정보) 연동이 필요합니다. "데이터 정보" 탭에서 확인하세요.</p>' : ''}
  </div>
  <div class="station-grid">${stations.map(station => {
    const s = currentStation(station.id);
    const facilitySummary = s.noFacility
      ? '장애인 편의시설 정보 없음'
      : s.elevator
        ? `엘리베이터 ${s.capacityKg}kg${s.doorWidthEstimated ? ' · 문폭 90cm(법정기준 추정치, 실측 아님)' : s.doorWidthCm ? ` · 문폭 ${s.doorWidthCm}cm` : ''}`
        : '엘리베이터 없음 · 에스컬레이터만 이용 가능';
    return `<article class="station-card ${s.noFacility ? 'unavailable' : ''}"><div><span class="line-list">${s.lines.map(line => `<b style="background:${lineColors[line]}">${line}</b>`).join('')}</span><h3>${s.name}</h3></div><span class="status ${s.noFacility ? 'off' : 'on'}">${s.noFacility ? '우회 필요' : '이용 가능'}</span><p>${facilitySummary}</p><small>${escape(s.note)}</small>${facilityListHtml(s.name)}</article>`;
  }).join('')}</div></section>`;
}
function sourcesView() { return `<section class="sources-page"><div class="page-heading"><p class="eyebrow">신뢰할 수 있는 데이터</p><h2>공공데이터 연결</h2><p>공공데이터 키는 서버에만 보관하고, 앱에는 노출하지 않습니다.</p></div><div class="source-list">${dataSources.map(source => `<a href="${source.url}" target="_blank" rel="noreferrer"><span>◫</span><div><strong>${source.name}</strong><p>${source.detail}</p></div><b>↗</b></a>`).join('')}</div><div class="sync-card"><div><span class="sync-icon">↻</span><div><h3>서울교통공사 시설 정보 조회</h3><p>보안 서버를 통해 엘리베이터 현황을 조회합니다.</p></div></div><div class="sync-actions"><button data-action="sync" ${state.syncing ? 'disabled' : ''}>${state.syncing ? '조회 중...' : '시설 정보 연결 확인'}</button></div>${state.syncMessage ? `<p class="sync-message">${escape(state.syncMessage)}</p>` : ''}</div><aside class="architecture"><strong>안전한 API 키 처리</strong><p>공공 API → Firebase 서버 함수 → 앱. API 키는 Firebase Secret에만 저장되며 브라우저와 배포 파일에는 포함되지 않습니다.</p></aside></section>`; }
function adminView() { return `<form method="dialog" class="admin-panel"><button class="dialog-close" value="close" aria-label="닫기">×</button><p class="eyebrow">운영자 도구</p><h2>시설 상태·공지 관리</h2><p>현재 변경 사항은 이 기기에만 저장됩니다. 실서비스에서는 인증된 관리자 DB로 연결하세요.</p><label>대상 역<select id="admin-station">${stationOptions(state.from)}</select></label><div class="admin-checks"><label><input id="admin-elevator" type="checkbox" ${currentStation(state.from).elevator ? 'checked' : ''}> 엘리베이터 이용 가능</label><label><input id="admin-escalator" type="checkbox" ${currentStation(state.from).escalator ? 'checked' : ''}> 에스컬레이터 이용 가능</label></div><label>안내 공지<input id="admin-notice" maxlength="120" placeholder="예: 3번 출구 엘리베이터 정기점검 (7/25 10:00~15:00)" /></label><button type="button" class="find-button" data-action="save-admin">변경사항 저장</button></form>`; }

function bindEvents() {
  document.querySelectorAll('[data-profile]').forEach(button => button.addEventListener('click', () => { state.profile = button.dataset.profile; state.result = null; render(); }));
  document.querySelectorAll('[data-tab]').forEach(button => button.addEventListener('click', () => { state.activeTab = button.dataset.tab; render(); }));
  document.querySelector('[data-action="find-route"]')?.addEventListener('click', findRoute);
  document.querySelector('[data-action="admin"]')?.addEventListener('click', () => document.querySelector('#admin-dialog').showModal());
  document.querySelector('[data-action="save-admin"]')?.addEventListener('click', saveAdmin);
  document.querySelector('[data-action="sync"]')?.addEventListener('click', syncFacilities);
  document.querySelector('[data-action="load-facilities"]')?.addEventListener('click', loadFacilities);
}
function saveAdmin() { const id = document.querySelector('#admin-station').value; const elevator = document.querySelector('#admin-elevator').checked; const escalator = document.querySelector('#admin-escalator').checked; const message = document.querySelector('#admin-notice').value.trim(); state.overrides[id] = { elevator, escalator, noFacility: !elevator && !escalator }; if (message) state.notices.push({ stationId: id, message }); localStorage.setItem('wheelway-overrides', JSON.stringify(state.overrides)); localStorage.setItem('wheelway-notices', JSON.stringify(state.notices)); document.querySelector('#admin-dialog').close(); state.result = null; render(); }
async function syncFacilities() { state.syncing = true; state.syncMessage = ''; render(); try { const rows = await getSeoulFacilities({ stationName: currentStation(state.from).name }); state.syncMessage = `${currentStation(state.from).name}역 엘리베이터 ${rows.length}건을 보안 서버를 통해 조회했습니다.`; } catch (error) { state.syncMessage = error.message; } finally { state.syncing = false; render(); } }
async function loadFacilities() { state.facilityLoading = true; state.facilityError = ''; render(); try { state.facilityIndex = await loadFacilityIndex(); } catch (error) { state.facilityError = error.message; } finally { state.facilityLoading = false; render(); } }

function buildLegs(result) {
  return result.groups.map((group, index) => {
    const fromName = currentStation(group.edges[0].from).name;
    const toName = currentStation(group.edges.at(-1).to).name;
    const isTransfer = index < result.groups.length - 1;
    const transferNote = isTransfer ? result.transferStations[index]?.note ?? '' : '';
    return { line: group.line, fromName, toName, minutes: group.edges.reduce((sum, edge) => sum + edge.minutes, 0), isTransfer, transferNote };
  });
}

async function findRoute() {
  state.from = document.querySelector('#from').value;
  state.to = document.querySelector('#to').value;
  state.result = getRoute({ ...state, stations });
  state.journey = null; state.journeyError = '';
  const hasRoute = state.result && !state.result.error;
  state.journeyLoading = hasRoute;
  render();
  if (!hasRoute) return;
  try {
    const legs = buildLegs(state.result);
    state.journey = await buildJourney(currentStation(state.from).name, currentStation(state.to).name, legs);
  } catch (error) {
    state.journeyError = error.message;
  } finally {
    state.journeyLoading = false;
    render();
  }
}

if ('serviceWorker' in navigator) navigator.serviceWorker.register('/sw.js').catch(() => {});
render();
