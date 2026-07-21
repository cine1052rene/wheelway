import { connections } from '../data/network.js';

const profileRules = {
  crutch: { label: '목발 이용', transferPenalty: 3, minimumKg: 0, minimumDoor: 0, allowed: station => station.elevator || station.escalator },
  manual: { label: '수동 휠체어', transferPenalty: 6, minimumKg: 0, minimumDoor: 0, allowed: station => station.elevator },
  electric: { label: '전동 휠체어', transferPenalty: 7, minimumKg: 1000, minimumDoor: 90, allowed: station => station.elevator && station.capacityKg >= 1000 && station.doorWidthCm >= 90 }
};

export function validateStation(station, profile) {
  const rule = profileRules[profile];
  return rule.allowed(station);
}

export function getRoute({ from, to, profile, stations, overrides = {} }) {
  const rule = profileRules[profile];
  const stationMap = new Map(stations.map(station => [station.id, { ...station, ...(overrides[station.id] ?? {}) }]));
  const origin = stationMap.get(from);
  const destination = stationMap.get(to);
  if (!origin || !destination) return { error: '출발역과 도착역을 선택하세요.' };
  if (!validateStation(origin, profile)) return { error: `${origin.name}역은 ${rule.label} 기준으로 이용 가능한 편의시설 정보가 없습니다.` };
  if (!validateStation(destination, profile)) return { error: `${destination.name}역은 ${rule.label} 기준으로 이용 가능한 편의시설 정보가 없습니다.` };

  const queue = [{ id: from, cost: 0, line: null, path: [] }];
  const best = new Map([[`${from}:`, 0]]);
  while (queue.length) {
    queue.sort((a, b) => a.cost - b.cost);
    const current = queue.shift();
    if (current.id === to) return formatRoute(current.path, stationMap, profile);
    for (const [a, b, line, minutes] of connections) {
      if (a !== current.id && b !== current.id) continue;
      const next = a === current.id ? b : a;
      const nextStation = stationMap.get(next);
      if (!rule.allowed(nextStation)) continue;
      const isTransfer = current.line && current.line !== line;
      const cost = current.cost + minutes + (isTransfer ? rule.transferPenalty : 0);
      const key = `${next}:${line}`;
      if ((best.get(key) ?? Infinity) <= cost) continue;
      best.set(key, cost);
      queue.push({ id: next, cost, line, path: [...current.path, { from: current.id, to: next, line, minutes, isTransfer }] });
    }
  }
  return { error: '현재 조건을 모두 만족하는 경로를 찾지 못했습니다. 다른 출발·도착역 또는 이용 유형을 확인하세요.' };
}

function formatRoute(path, stationMap, profile) {
  const groups = [];
  path.forEach(edge => {
    const last = groups.at(-1);
    if (last?.line === edge.line) last.edges.push(edge);
    else groups.push({ line: edge.line, edges: [edge] });
  });
  const transferStations = path.filter(edge => edge.isTransfer).map(edge => stationMap.get(edge.from));
  const rideMinutes = path.reduce((sum, edge) => sum + edge.minutes, 0);
  const extraMinutes = profileRules[profile].transferPenalty * transferStations.length;
  return {
    groups,
    transferStations,
    rideMinutes,
    totalMinutes: rideMinutes + extraMinutes,
    pathStations: [stationMap.get(path[0].from), ...path.map(edge => stationMap.get(edge.to))],
    profileLabel: profileRules[profile].label
  };
}
