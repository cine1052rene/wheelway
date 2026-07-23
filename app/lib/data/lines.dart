import 'stations.dart';

/// 데이터에 실제로 존재하는 노선 목록(오름차순).
///
/// 예전엔 "1~8호선"이 필터 그리드 등에 하드코딩돼 있었다. 수도권은 9호선·
/// 공항철도·GTX처럼 계속 늘어나는데, 하드코딩은 그때마다 여러 파일을 손봐야
/// 한다. 대신 실제 역 데이터(kStations)에서 존재하는 노선을 동적으로
/// 추출해, `scripts/build_network.py` 재실행으로 새 노선이 데이터에
/// 추가되기만 하면 필터·배지가 코드 수정 없이 자동으로 늘어나게 한다.
final List<String> kAvailableLines = _computeAvailableLines();

List<String> _computeAvailableLines() {
  final set = <String>{};
  for (final s in kStations) {
    set.addAll(s.lines);
  }
  final list = set.toList();
  list.sort((a, b) {
    final an = int.tryParse(a);
    final bn = int.tryParse(b);
    if (an != null && bn != null) return an.compareTo(bn);
    if (an != null) return -1; // 숫자 노선을 먼저
    if (bn != null) return 1;
    return a.compareTo(b);
  });
  return list;
}
