import '../data/connections.dart';
import '../models/route.dart';
import '../models/station.dart';

/// 전동 휠체어 통과 최소 문 폭(cm). 단, 실측 데이터가 있을 때만 게이팅에 사용.
/// doorWidthCm이 null(실측 전)이면 지어낸 값으로 통과/차단을 결정하지 않는다.
const int kMinDoorCm = 90;

/// 프로필별 이용 가능 판정. (웹 routeEngine.js와 동일 로직)
bool stationAllowed(Station s, MobilityProfile profile) {
  switch (profile) {
    case MobilityProfile.crutch:
      return s.elevator || s.escalator;
    case MobilityProfile.manual:
      return s.elevator;
    case MobilityProfile.electric:
      return s.elevator &&
          s.capacityKg >= 1000 &&
          (s.doorWidthCm == null || s.doorWidthCm! >= kMinDoorCm);
  }
}

/// 다익스트라 경로 탐색 엔진.
/// - 인접 리스트(간선 1회 인덱싱) + 바이너리 최소 힙 + previous 포인터 역추적.
/// - (역, 진입 노선) 쌍을 상태 키로 사용해 환승 페널티를 정확히 반영한다.
class RouteEngine {
  RouteEngine({List<Station>? stations})
      : _stationMap = {for (final s in (stations ?? const [])) s.id: s} {
    _buildAdjacency();
  }

  final Map<String, Station> _stationMap;
  final Map<String, List<_Adj>> _adjacency = {};

  void _buildAdjacency() {
    void add(String from, String to, String line, int min) {
      (_adjacency[from] ??= []).add(_Adj(to, line, min));
    }

    for (final (a, b, line, min) in kConnections) {
      add(a, b, line, min);
      add(b, a, line, min);
    }
  }

  /// 경로를 계산한다. 실패 시 [RouteException]을 던진다.
  RouteResult getRoute({
    required String fromId,
    required String toId,
    required MobilityProfile profile,
  }) {
    final origin = _stationMap[fromId];
    final dest = _stationMap[toId];
    if (origin == null || dest == null) {
      throw RouteException('출발역과 도착역을 선택하세요.');
    }
    if (!stationAllowed(origin, profile)) {
      throw RouteException(
          '${origin.name}역은 ${profile.label} 기준으로 이용 가능한 편의시설 정보가 없습니다.');
    }
    if (!stationAllowed(dest, profile)) {
      throw RouteException(
          '${dest.name}역은 ${profile.label} 기준으로 이용 가능한 편의시설 정보가 없습니다.');
    }

    final startKey = '$fromId:';
    final heap = _MinHeap()..push(_Node(fromId, 0, null, startKey));
    final best = <String, int>{startKey: 0};
    final previous = <String, _Prev>{};

    while (heap.isNotEmpty) {
      final cur = heap.pop();
      if ((best[cur.key] ?? 1 << 30) < cur.cost) continue; // stale
      if (cur.id == toId) {
        return _format(_reconstruct(previous, cur.key), profile);
      }
      for (final adj in _adjacency[cur.id] ?? const <_Adj>[]) {
        final next = _stationMap[adj.to];
        if (next == null || !stationAllowed(next, profile)) continue;
        final isTransfer = cur.line != null && cur.line != adj.line;
        final cost =
            cur.cost + adj.minutes + (isTransfer ? profile.transferPenalty : 0);
        final key = '${adj.to}:${adj.line}';
        if ((best[key] ?? 1 << 30) <= cost) continue;
        best[key] = cost;
        previous[key] = _Prev(
          cur.key,
          RouteEdge(
            from: cur.id,
            to: adj.to,
            line: adj.line,
            minutes: adj.minutes,
            isTransfer: isTransfer,
          ),
        );
        heap.push(_Node(adj.to, cost, adj.line, key));
      }
    }
    throw RouteException(
        '현재 조건을 모두 만족하는 경로를 찾지 못했습니다. 다른 출발·도착역 또는 이용 유형을 확인하세요.');
  }

  List<RouteEdge> _reconstruct(Map<String, _Prev> previous, String key) {
    final path = <RouteEdge>[];
    var cursor = key;
    while (previous.containsKey(cursor)) {
      final p = previous[cursor]!;
      path.add(p.edge);
      cursor = p.prevKey;
    }
    return path.reversed.toList();
  }

  RouteResult _format(List<RouteEdge> path, MobilityProfile profile) {
    final groups = <RouteGroup>[];
    for (final edge in path) {
      if (groups.isNotEmpty && groups.last.line == edge.line) {
        groups.last.edges.add(edge);
      } else {
        groups.add(RouteGroup(edge.line, [edge]));
      }
    }
    final transferStations = [
      for (final e in path)
        if (e.isTransfer) _stationMap[e.from]!
    ];
    final rideMinutes = path.fold<int>(0, (sum, e) => sum + e.minutes);
    final extra = profile.transferPenalty * transferStations.length;
    return RouteResult(
      groups: groups,
      transferStations: transferStations,
      rideMinutes: rideMinutes,
      totalMinutes: rideMinutes + extra,
      pathStations: [
        _stationMap[path.first.from]!,
        for (final e in path) _stationMap[e.to]!,
      ],
      profileLabel: profile.label,
    );
  }

  /// route 결과를 실제 이동 순서로 확장할 노선 구간 리스트로 변환.
  /// isTransfer는 "이 구간의 도착역에서 환승하는가"를 뜻한다 —
  /// 마지막 구간이 아니면(뒤에 탈 노선이 있으면) 도착역은 환승역이다.
  List<RouteLeg> buildLegs(RouteResult result) {
    final groups = result.groups;
    return [
      for (int i = 0; i < groups.length; i++)
        RouteLeg(
          line: groups[i].line,
          fromName: _stationMap[groups[i].edges.first.from]!.name,
          toName: _stationMap[groups[i].edges.last.to]!.name,
          minutes: groups[i].edges.fold<int>(0, (s, e) => s + e.minutes),
          isTransfer: i < groups.length - 1,
        ),
    ];
  }
}

class _Adj {
  final String to;
  final String line;
  final int minutes;
  const _Adj(this.to, this.line, this.minutes);
}

class _Node {
  final String id;
  final int cost;
  final String? line;
  final String key;
  const _Node(this.id, this.cost, this.line, this.key);
}

class _Prev {
  final String prevKey;
  final RouteEdge edge;
  const _Prev(this.prevKey, this.edge);
}

/// 비용 기준 최소 힙.
class _MinHeap {
  final List<_Node> _items = [];
  bool get isNotEmpty => _items.isNotEmpty;

  void push(_Node item) {
    _items.add(item);
    var i = _items.length - 1;
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_items[parent].cost <= _items[i].cost) break;
      final tmp = _items[parent];
      _items[parent] = _items[i];
      _items[i] = tmp;
      i = parent;
    }
  }

  _Node pop() {
    final top = _items[0];
    final last = _items.removeLast();
    if (_items.isNotEmpty) {
      _items[0] = last;
      var i = 0;
      final n = _items.length;
      while (true) {
        final left = i * 2 + 1;
        final right = i * 2 + 2;
        var smallest = i;
        if (left < n && _items[left].cost < _items[smallest].cost) smallest = left;
        if (right < n && _items[right].cost < _items[smallest].cost) smallest = right;
        if (smallest == i) break;
        final tmp = _items[smallest];
        _items[smallest] = _items[i];
        _items[i] = tmp;
        i = smallest;
      }
    }
    return top;
  }
}
