import '../data/connections.dart';

/// 노선별 역 순서를 kConnections 원본 순서에서 재구성한다.
///
/// `build_network.py`가 각 노선의 간선을 본선은 stnNo 오름차순, 그 뒤
/// 지선 순으로 이미 정렬해 기록해뒀으므로, 간선을 원본 순서대로 이어
/// 붙이면 실제 노선 순서가 복원된다. 분기(지선)나 2호선처럼 순환선이라
/// 단일 사슬로 안 이어지는 구간은 별도 사슬로 분리해 반환한다.
///
/// ⚠️ 실제 지리 좌표(위경도) 없이 위상(연결 순서)만으로 만든 **개략적
/// 노선도**다. 지하철 실제 노선도처럼 정확한 굴곡·교차를 표현하려면
/// 역별 좌표 데이터를 별도로 확보해야 한다(추후 과제).
class LineTopology {
  LineTopology._();

  static final Map<String, List<List<String>>> _cache = {};

  /// 특정 노선의 역 순서 사슬들(보통 1개, 지선이 있으면 여러 개).
  static List<List<String>> chainsFor(String line) {
    return _cache.putIfAbsent(line, () => _buildChains(line));
  }

  static List<List<String>> _buildChains(String line) {
    final chains = <List<String>>[];
    List<String>? current;
    for (final edge in kConnections) {
      if (edge.$3 != line) continue;
      final from = edge.$1, to = edge.$2;
      if (current != null && current.last == from) {
        current.add(to);
      } else {
        current = [from, to];
        chains.add(current);
      }
    }
    return chains;
  }
}
