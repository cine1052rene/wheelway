import { getSeoulFacilities, getQuickExit } from './publicData.js';

/** 특정 역의 엘리베이터를 '지상↔지하 진입용'과 '역 구내 이동용'으로 나눠서 불러옵니다. */
async function loadElevators(stationName) {
  const rows = await getSeoulFacilities({ type: 'elevator', stationName }).catch(() => []);
  const ground = [];
  const inner = [];
  rows.forEach(row => {
    const entry = { exit: row.vcntEntrcNo || '', detail: row.dtlPstn || '', from: row.bgngFlr || '', to: row.endFlr || '' };
    const isGround = row.bgngFlrGrndUdgdSe === '지상' || row.endFlrGrndUdgdSe === '지상';
    (isGround ? ground : inner).push(entry);
  });
  return { ground, inner };
}

/** 하차역 기준으로 엘리베이터와 가장 가까운 열차 칸(출입문) 후보를 불러옵니다. */
async function loadCarCandidates(stationName) {
  const rows = await getQuickExit(stationName).catch(() => []);
  return rows
    .filter(row => row.plfmCmgFac?.includes('엘리베이터'))
    .map(row => ({ door: row.qckgffVhclDoorNo || '?', direction: row.upbdnbSe || '', toward: row.drtnInfo || '', floor: row.fwkPstnNm || '' }));
}

/**
 * 경로 결과를 실제 이동 순서(지상 진입 → 승차 칸 안내 → 환승/하차 → 지상 이동)로 확장하고,
 * 각 단계에 필요한 실제 공공데이터(엘리베이터 위치, 하차 칸번호)를 함께 불러옵니다.
 * @param {string} originName 출발역 실명
 * @param {string} destName 도착역 실명
 * @param {{line:string, fromName:string, toName:string, minutes:number, isTransfer:boolean, transferNote:string}[]} legs
 */
export async function buildJourney(originName, destName, legs) {
  const stationNames = [...new Set([originName, ...legs.map(leg => leg.toName)])];
  const elevatorEntries = await Promise.all(stationNames.map(async name => [name, await loadElevators(name)]));
  const elevatorMap = new Map(elevatorEntries);

  const carEntries = await Promise.all(legs.map(async leg => [leg.toName, await loadCarCandidates(leg.toName)]));
  const carMap = new Map(carEntries);

  return {
    enter: { station: originName, elevators: elevatorMap.get(originName)?.ground ?? [] },
    legs: legs.map(leg => ({
      ...leg,
      cars: carMap.get(leg.toName) ?? [],
      arrivalElevators: leg.isTransfer ? elevatorMap.get(leg.toName)?.inner ?? [] : elevatorMap.get(leg.toName)?.ground ?? []
    }))
  };
}
