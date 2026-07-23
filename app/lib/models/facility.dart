/// 엘리베이터/에스컬레이터 편의시설 1건 (서울교통공사 공개데이터).
/// 웹 publicData.js의 정규화 로직과 동일한 필드를 사용한다.
enum FacilityKind { elevator, escalator }

class Facility {
  final FacilityKind kind;
  final String stationName; // stnNm
  final String exit; // vcntEntrcNo — 출구 위치(숫자/텍스트 혼재)
  final String detail; // dtlPstn — 상세 위치
  final String capacityKg; // pscpWht — 정격하중(원본 문자열)
  final String direction; // upbdnbSe — 상/하행 등
  final String floorFrom; // bgngFlr — 시작 층
  final String floorTo; // endFlr — 끝 층
  final bool isGroundEntrance; // 지상↔지하 진입용(true) vs 역 구내 이동용(false)

  const Facility({
    required this.kind,
    required this.stationName,
    required this.exit,
    required this.detail,
    required this.capacityKg,
    required this.direction,
    this.floorFrom = '',
    this.floorTo = '',
    this.isGroundEntrance = false,
  });

  factory Facility.fromRow(Map<String, dynamic> row, FacilityKind kind) {
    String s(dynamic v) => (v ?? '').toString().trim();
    final ground =
        s(row['bgngFlrGrndUdgdSe']) == '지상' || s(row['endFlrGrndUdgdSe']) == '지상';
    return Facility(
      kind: kind,
      stationName: s(row['stnNm']),
      exit: s(row['vcntEntrcNo']),
      detail: s(row['dtlPstn']),
      capacityKg: s(row['pscpWht']),
      direction: s(row['upbdnbSe']),
      floorFrom: s(row['bgngFlr']),
      floorTo: s(row['endFlr']),
      isGroundEntrance: ground,
    );
  }
}

/// 도착역 기준 "가장 가까운 열차 칸" 1건 (빠른하차 공개데이터).
class QuickExit {
  final String doorNo; // qckgffVhclDoorNo — "8-1" 같은 칸-문 번호
  final String facility; // plfmCmgFac — 인접 시설(엘리베이터/계단 등)
  final String direction; // upbdnbSe — 상/하행
  final String toward; // drtnInfo — 방면
  final String floor; // fwkPstnNm — 역사 내 위치

  const QuickExit({
    required this.doorNo,
    required this.facility,
    required this.direction,
    required this.toward,
    required this.floor,
  });

  factory QuickExit.fromRow(Map<String, dynamic> row) {
    String s(dynamic v) => (v ?? '').toString().trim();
    return QuickExit(
      doorNo: s(row['qckgffVhclDoorNo']),
      facility: s(row['plfmCmgFac']),
      direction: s(row['upbdnbSe']),
      toward: s(row['drtnInfo']),
      floor: s(row['fwkPstnNm']),
    );
  }

  bool get nearElevator => facility.contains('엘리베이터');
}
