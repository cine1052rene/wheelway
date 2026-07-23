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

// 인접 리스트: connections(간선 목록)를 역 ID 기준으로 한 번만 인덱싱해 캐시.
// 매번 getRoute()가 호출될 때마다 전체 간선을 선형 스캔하던 O(V×E) 병목 제거.
// connections는 정적 데이터라 배열 참조가 바뀌지 않는 한 재사용 가능.
let adjacencyCache = null;
let adjacencySource = null;

function buildAdjacency(edges) {
  if (adjacencySource === edges && adjacencyCache) return adjacencyCache;
  const map = new Map();
  const addEdge = (from, to, line, minutes) => {
    if (!map.has(from)) map.set(from, []);
    map.get(from).push({ to, line, minutes });
  };
  for (const [a, b, line, minutes] of edges) {
    addEdge(a, b, line, minutes);
    addEdge(b, a, line, minutes);
  }
  adjacencyCache = map;
  adjacencySource = edges;
  return map;
}

// 최소 힙(binary heap): 매 반복마다 큐 전체를 sort()하던 O(V log V) 병목을
// 삽입/추출 각각 O(log V)로 대체.
class MinHeap {
  constructor() {
    this.items = [];
  }

  get size() {
    return this.items.length;
  }

  push(item) {
    const items = this.items;
    items.push(item);
    let i = items.length - 1;
    while (i > 0) {
      const parent = (i - 1) >> 1;
      if (items[parent].cost <= items[i].cost) break;
      [items[parent], items[i]] = [items[i], items[parent]];
      i = parent;
    }
  }

  pop() {
    const items = this.items;
    const top = items[0];
    const last = items.pop();
    if (items.length) {
      items[0] = last;
      let i = 0;
      const n = items.length;
      while (true) {
        const left = i * 2 + 1;
        const right = i * 2 + 2;
        let smallest = i;
        if (left < n && items[left].cost < items[smallest].cost) smallest = left;
        if (right < n && items[right].cost < items[smallest].cost) smallest = right;
        if (smallest === i) break;
        [items[smallest], items[i]] = [items[i], items[smallest]];
        i = smallest;
      }
    }
    return top;
  }
}

// 도착 시 한 번만 역추적하도록 previous 포인터로 경로를 기록.
// (기존에는 간선을 확장할 때마다 path 배열 전체를 복사해 GC 부담이 컸음)
function reconstructPath(previous, key) {
  const path = [];
  let cursor = key;
  while (previous.has(cursor)) {
    const { prevKey, edge } = previous.get(cursor);
    path.push(edge);
    cursor = prevKey;
  }
  return path.reverse();
}

export function getRoute({ from, to, profile, stations, overrides = {} }) {
  const rule = profileRules[profile];
  const stationMap = new Map(stations.map(station => [station.id, { ...station, ...(overrides[station.id] ?? {}) }]));
  const origin = stationMap.get(from);
  const destination = stationMap.get(to);
  if (!origin || !destination) return { error: '출발역과 도착역을 선택하세요.' };
  if (!validateStation(origin, profile)) return { error: `${origin.name}역은 ${rule.label} 기준으로 이용 가능한 편의시설 정보가 없습니다.` };
  if (!validateStation(destination, profile)) return { error: `${destination.name}역은 ${rule.label} 기준으로 이용 가능한 편의시설 정보가 없습니다.` };

  const adjacency = buildAdjacency(connections);
  const startKey = `${from}:`;
  const heap = new MinHeap();
  heap.push({ id: from, cost: 0, line: null, key: startKey });
  const best = new Map([[startKey, 0]]);
  const previous = new Map();

  while (heap.size) {
    const current = heap.pop();
    // best가 이미 더 나은 값으로 갱신된 stale 항목이면 확장하지 않고 건너뜀 (lazy deletion)
    if ((best.get(current.key) ?? Infinity) < current.cost) continue;
    if (current.id === to) return formatRoute(reconstructPath(previous, current.key), stationMap, profile);

    const edges = adjacency.get(current.id) ?? [];
    for (const { to: next, line, minutes } of edges) {
      const nextStation = stationMap.get(next);
      if (!nextStation || !rule.allowed(nextStation)) continue;
      const isTransfer = current.line && current.line !== line;
      const cost = current.cost + minutes + (isTransfer ? rule.transferPenalty : 0);
      const key = `${next}:${line}`;
      if ((best.get(key) ?? Infinity) <= cost) continue;
      best.set(key, cost);
      previous.set(key, { prevKey: current.key, edge: { from: current.id, to: next, line, minutes, isTransfer } });
      heap.push({ id: next, cost, line, key });
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
