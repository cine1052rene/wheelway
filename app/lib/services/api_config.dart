/// 백엔드 설정.
///
/// 기존 웹앱과 동일한 Firebase Functions(보안 프록시)를 그대로 재사용한다.
/// 공공 API 키는 서버(Firebase Secret)에만 있고 앱에는 절대 포함하지 않는다.
/// 엔드포인트(firebase.json rewrites 기준):
///   GET /api/facilities?stnNm=&type=elevator|escalator
///   GET /api/quickExit?stnNm=            (도착역 기준 빠른 하차 칸번호)
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://emeraldworks.web.app';

  static const String facilities = '/api/facilities';
  static const String quickExit = '/api/quickExit';

  static const Duration timeout = Duration(seconds: 12);
}
