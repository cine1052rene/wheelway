import 'station.dart';

/// 이동 프로필(이용자 유형).
enum MobilityProfile { crutch, manual, electric }

extension MobilityProfileX on MobilityProfile {
  String get label => switch (this) {
        MobilityProfile.crutch => '목발 이용',
        MobilityProfile.manual => '수동 휠체어',
        MobilityProfile.electric => '전동 휠체어',
      };

  int get transferPenalty => switch (this) {
        MobilityProfile.crutch => 3,
        MobilityProfile.manual => 6,
        MobilityProfile.electric => 7,
      };
}

/// 경로 간선 1개.
class RouteEdge {
  final String from;
  final String to;
  final String line;
  final int minutes;
  final bool isTransfer;
  const RouteEdge({
    required this.from,
    required this.to,
    required this.line,
    required this.minutes,
    required this.isTransfer,
  });
}

/// 같은 노선으로 이어지는 구간 묶음.
class RouteGroup {
  final String line;
  final List<RouteEdge> edges;
  const RouteGroup(this.line, this.edges);
}

/// 라우팅 결과(성공).
class RouteResult {
  final List<RouteGroup> groups;
  final List<Station> transferStations;
  final int rideMinutes;
  final int totalMinutes;
  final List<Station> pathStations;
  final String profileLabel;
  const RouteResult({
    required this.groups,
    required this.transferStations,
    required this.rideMinutes,
    required this.totalMinutes,
    required this.pathStations,
    required this.profileLabel,
  });
}

/// 실제 이동 순서로 확장하기 위한 노선 구간(출발/도착역 실명 포함).
class RouteLeg {
  final String line;
  final String fromName;
  final String toName;
  final int minutes;
  final bool isTransfer;
  const RouteLeg({
    required this.line,
    required this.fromName,
    required this.toName,
    required this.minutes,
    required this.isTransfer,
  });
}

/// 라우팅 예외(사용자에게 보여줄 메시지 포함).
class RouteException implements Exception {
  final String message;
  RouteException(this.message);
  @override
  String toString() => message;
}
