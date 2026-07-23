import 'facility.dart';

/// 하차역 기준 "엘리베이터와 가장 가까운 칸" 후보.
class CarCandidate {
  final String door; // qckgffVhclDoorNo, 예: "8-1"
  final String direction; // 상행/하행
  final String toward; // 방면
  final String floor; // 역사 내 위치
  const CarCandidate({
    required this.door,
    required this.direction,
    required this.toward,
    required this.floor,
  });
}

/// 실제 이동 순서로 확장한 한 구간(노선 승차 → 도착/환승).
class JourneyLeg {
  final String line;
  final String fromName;
  final String toName;
  final int minutes;
  final bool isTransfer;
  final List<CarCandidate> cars; // 도착역 기준 칸 후보
  final List<Facility> arrivalElevators; // 환승=구내, 도착=지상 엘리베이터
  const JourneyLeg({
    required this.line,
    required this.fromName,
    required this.toName,
    required this.minutes,
    required this.isTransfer,
    required this.cars,
    required this.arrivalElevators,
  });
}

/// 지상 진입 → 승차/환승 → 지상 진출 전체 타임라인.
class Journey {
  final String enterStation;
  final List<Facility> enterElevators; // 출발역 지상 진입 엘리베이터
  final List<JourneyLeg> legs;
  const Journey({
    required this.enterStation,
    required this.enterElevators,
    required this.legs,
  });
}
