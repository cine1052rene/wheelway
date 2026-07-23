import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/arrival.dart';
import '../models/facility.dart';
import 'api_config.dart';

/// 기존 Firebase Functions(보안 프록시)를 호출하는 클라이언트.
/// 웹 publicData.js와 동일한 엔드포인트·응답(`{ rows: [...] }`)을 사용한다.
class WheelwayApi {
  WheelwayApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Map<String, dynamic>>> _getRows(
    String path,
    Map<String, String> query,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final res = await _client.get(uri).timeout(ApiConfig.timeout);
    if (res.statusCode != 200) {
      throw WheelwayApiException('요청 실패 (${res.statusCode})');
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    final rows = (body is Map && body['rows'] is List) ? body['rows'] as List : const [];
    return rows.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }

  /// 특정 시설 유형 조회. stationName이 비면 서울 전역이 반환된다.
  Future<List<Facility>> fetchFacilities({
    FacilityKind kind = FacilityKind.elevator,
    String stationName = '',
  }) async {
    final rows = await _getRows(ApiConfig.facilities, {
      'type': kind == FacilityKind.elevator ? 'elevator' : 'escalator',
      if (stationName.isNotEmpty) 'stnNm': stationName,
    });
    return rows.map((r) => Facility.fromRow(r, kind)).toList();
  }

  /// 한 역의 엘리베이터+에스컬레이터를 함께 불러온다.
  Future<List<Facility>> fetchStationFacilities(String stationName) async {
    final results = await Future.wait([
      fetchFacilities(kind: FacilityKind.elevator, stationName: stationName),
      fetchFacilities(kind: FacilityKind.escalator, stationName: stationName),
    ]);
    return [...results[0], ...results[1]];
  }

  /// 도착역 기준 "가장 가까운 열차 칸" 조회.
  Future<List<QuickExit>> fetchQuickExit(String stationName) async {
    final rows = await _getRows(ApiConfig.quickExit, {'stnNm': stationName});
    return rows.map(QuickExit.fromRow).toList();
  }

  /// 실시간 도착정보 조회. 인증키의 "실시간 서비스" 승인 전에는 서버가
  /// 빈 목록을 돌려줄 수 있다 — 이 경우 UI에서 "불러올 수 없음"으로
  /// 안내하고 임의의 시간을 만들어 보여주지 않는다.
  Future<List<StationArrival>> fetchArrivals(String stationName) async {
    final rows = await _getRows(ApiConfig.arrivals, {'stnNm': stationName});
    return rows.map(StationArrival.fromRow).toList();
  }

  void dispose() => _client.close();
}

class WheelwayApiException implements Exception {
  final String message;
  WheelwayApiException(this.message);
  @override
  String toString() => message;
}
