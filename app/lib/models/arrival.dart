/// 서울시 지하철 실시간 도착정보 1건(data.seoul.go.kr swopenAPI).
///
/// ⚠️ 이 데이터셋은 같은 서울 열린데이터광장 계정 인증키라도 "실시간
/// 서비스" 별도 승인이 필요하다(사용 중인 키는 아직 승인 전 — 배포 후
/// ERROR-338 확인). 승인 전에는 조회 결과가 항상 비어 있을 수 있으며,
/// 그 경우 화면엔 "실시간 도착정보를 불러올 수 없습니다"만 보여주고
/// 절대 임의의 도착시간을 지어내 보여주지 않는다(실측 데이터 원칙).
// subwayId → 호선 번호. 서울시 지하철 실시간 API가 쓰는 표준 노선 코드로,
// 1001~1009는 1~9호선에 안정적으로 고정되어 있다(공식 문서 기준 상수 —
// 임의로 지어낸 매핑이 아님). 그 외 코드(GTX 등)는 아직 매핑이 불확실해
// 원본 코드를 그대로 보여준다.
const Map<String, String> _kSubwayIdToLine = {
  '1001': '1', '1002': '2', '1003': '3', '1004': '4',
  '1005': '5', '1006': '6', '1007': '7', '1008': '8', '1009': '9',
};

class StationArrival {
  final String lineName; // subwayId를 사람이 읽을 수 있는 형태로는 변환하지 않고 원문 유지
  final String trainLineNm; // 예: "성수행 - 신정네거리"
  final String arrivalMessage; // arvlMsg2, 예: "전역 도착"
  final String arrivalDetail; // arvlMsg3, 예: "3분 후 (신정네거리)"
  final int? secondsToArrival; // barvlDt(초)
  final String direction; // updnLine, 상행/하행

  const StationArrival({
    required this.lineName,
    required this.trainLineNm,
    required this.arrivalMessage,
    required this.arrivalDetail,
    required this.secondsToArrival,
    required this.direction,
  });

  factory StationArrival.fromRow(Map<String, dynamic> row) {
    String s(dynamic v) => (v ?? '').toString().trim();
    final barvlDt = int.tryParse(s(row['barvlDt']));
    return StationArrival(
      lineName: s(row['subwayId']),
      trainLineNm: s(row['trainLineNm']),
      arrivalMessage: s(row['arvlMsg2']),
      arrivalDetail: s(row['arvlMsg3']),
      secondsToArrival: barvlDt,
      direction: s(row['updnLine']),
    );
  }

  /// 표시용 호선 번호(매핑 안 되면 null — 이 경우 UI는 원본 텍스트로 대체).
  String? get lineNumber => _kSubwayIdToLine[lineName];

  String get minutesLabel {
    final sec = secondsToArrival;
    if (sec == null) return arrivalMessage.isNotEmpty ? arrivalMessage : '정보 없음';
    if (sec <= 30) return '곧 도착';
    final min = (sec / 60).ceil();
    return '$min분 후';
  }
}
