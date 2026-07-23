/// 지하철 역 1개 (접근성 데이터 포함).
///
/// [doorWidthCm]는 실측 전이면 null이며, 라우팅은 실측되지 않은 문 폭으로
/// 통과/차단을 결정하지 않는다([doorWidthStatus]로만 '실측 전' 안내).
class Station {
  final String id;
  final String name;
  final List<String> lines;
  final bool elevator;
  final bool escalator;
  final int capacityKg; // 엘리베이터 정격하중(실측). 엘리베이터 없으면 0.
  final int? doorWidthCm; // null = 실측 전
  final String? doorWidthStatus; // 예: '실측 전'
  final String note;

  const Station({
    required this.id,
    required this.name,
    required this.lines,
    required this.elevator,
    required this.escalator,
    required this.capacityKg,
    required this.doorWidthCm,
    required this.doorWidthStatus,
    required this.note,
  });

  /// 관리자 오버라이드(엘리베이터/에스컬레이터 상태 변경) 적용본을 만든다.
  Station copyWith({bool? elevator, bool? escalator}) => Station(
        id: id,
        name: name,
        lines: lines,
        elevator: elevator ?? this.elevator,
        escalator: escalator ?? this.escalator,
        capacityKg: capacityKg,
        doorWidthCm: doorWidthCm,
        doorWidthStatus: doorWidthStatus,
        note: note,
      );

  bool get hasFacility => elevator || escalator;
}
