import '../models/facility.dart';
import '../models/journey.dart';
import '../models/route.dart';
import 'wheelway_api.dart';

/// 경로(RouteLeg 목록)를 실제 이동 순서 타임라인으로 확장하고, 각 단계에
/// 필요한 실제 공공데이터(엘리베이터 위치·하차 칸번호)를 병렬로 불러온다.
/// (웹 journey.js와 동일한 로직/필드.)
class JourneyService {
  JourneyService(this._api);
  final WheelwayApi _api;

  Future<({List<Facility> ground, List<Facility> inner})> _loadElevators(
      String station) async {
    List<Facility> rows;
    try {
      rows = await _api.fetchFacilities(
          kind: FacilityKind.elevator, stationName: station);
    } catch (_) {
      rows = const [];
    }
    final ground = <Facility>[];
    final inner = <Facility>[];
    for (final f in rows) {
      (f.isGroundEntrance ? ground : inner).add(f);
    }
    return (ground: ground, inner: inner);
  }

  Future<List<CarCandidate>> _loadCars(String station) async {
    List<QuickExit> rows;
    try {
      rows = await _api.fetchQuickExit(station);
    } catch (_) {
      rows = const [];
    }
    return rows
        .where((r) => r.nearElevator)
        .map((r) => CarCandidate(
              door: r.doorNo.isEmpty ? '?' : r.doorNo,
              direction: r.direction,
              toward: r.toward,
              floor: r.floor,
            ))
        .toList();
  }

  Future<Journey> buildJourney({
    required String originName,
    required List<RouteLeg> legs,
  }) async {
    // 엘리베이터 대상 역: 출발역 + 각 구간 도착역(중복 제거)
    final stationNames = <String>{originName, for (final l in legs) l.toName};
    final elevatorFutures = {
      for (final name in stationNames) name: _loadElevators(name),
    };
    final carFutures = {
      for (final l in legs) l.toName: _loadCars(l.toName),
    };

    // 모든 요청을 동시에 대기
    await Future.wait([...elevatorFutures.values, ...carFutures.values]);
    final elevators = {
      for (final e in elevatorFutures.entries) e.key: await e.value,
    };
    final cars = {
      for (final e in carFutures.entries) e.key: await e.value,
    };

    return Journey(
      enterStation: originName,
      enterElevators: elevators[originName]?.ground ?? const [],
      legs: [
        for (final l in legs)
          JourneyLeg(
            line: l.line,
            fromName: l.fromName,
            toName: l.toName,
            minutes: l.minutes,
            isTransfer: l.isTransfer,
            cars: cars[l.toName] ?? const [],
            arrivalElevators: l.isTransfer
                ? (elevators[l.toName]?.inner ?? const [])
                : (elevators[l.toName]?.ground ?? const []),
          ),
      ],
    );
  }
}
