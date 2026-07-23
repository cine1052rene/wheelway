/// 백엔드 설정.
///
/// 기존 웹앱과 동일한 Firebase Functions(보안 프록시)를 그대로 재사용한다.
/// 공공 API 키는 서버(Firebase Secret)에만 있고 앱에는 절대 포함하지 않는다.
/// 엔드포인트(firebase.json rewrites 기준):
///   GET /api/facilities?stnNm=&type=elevator|escalator
///   GET /api/quickExit?stnNm=            (도착역 기준 빠른 하차 칸번호)
///   GET /api/arrivals?stnNm=             (실시간 도착정보 — 인증키 실시간
///                                         서비스 승인 전에는 빈 결과)
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://emeraldworks.web.app';

  static const String facilities = '/api/facilities';
  static const String quickExit = '/api/quickExit';
  static const String arrivals = '/api/arrivals';

  // 백엔드(facilities)가 서울 전역 데이터를 페이지네이션 후 서버측 필터링하는
  // 구조라 escalator 조회가 실측 ~11.6s까지 걸린다(콜드스타트 시 더). 12s로는
  // 부족해 타임아웃이 나므로 넉넉히 설정. (추후 백엔드 캐싱/역별 필터 최적화 필요.)
  static const Duration timeout = Duration(seconds: 30);
}
