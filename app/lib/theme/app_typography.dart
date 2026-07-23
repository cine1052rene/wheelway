import 'package:flutter/material.dart';

/// 타이포그래피 토큰 ("에메랄드 클리어").
///
/// 접근성 우선: 본문 최소 16sp, 캡션 최소 12sp(11 이하 금지). 색은 지정하지
/// 않아 ColorScheme.onSurface 등 테마 색을 그대로 상속한다(다크모드 자동 대응).
/// 시스템 글꼴 확대 배율은 임의 제한하지 않는다.
///
/// 폰트: 디자인 가이드는 Noto Sans KR을 권장하나, 번들 없이 fontFamily만
/// 지정하면 조용히 시스템 폰트로 폴백되므로(안드/iOS는 한글 폴백 정상 렌더),
/// 지금은 [fontFamily]=null(시스템 기본)로 두고 배포 전 Noto 번들 시 이 값만
/// 바꾼다. (수치/굵기/자간은 가이드 스펙 그대로.)
class AppTypography {
  AppTypography._();

  static const String? fontFamily = null;

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.5),
    displayMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w700, height: 1.28, letterSpacing: -0.25),
    displaySmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w700, height: 1.33, letterSpacing: 0),
    headlineLarge: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0),
    headlineMedium: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, height: 1.27, letterSpacing: 0),
    headlineSmall: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, height: 1.30, letterSpacing: 0),
    titleLarge: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0),
    titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w500, height: 1.375, letterSpacing: 0.1),
    titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.5),
    bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.25),
    bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1),
    labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5),
    labelSmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5),
  );

  /// 수치(칸번호·층수·거리) 표시용 — 향후 Noto Sans Mono 번들 시 fontFamily 지정.
  static const TextStyle monoNumber = TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700, height: 1.28, fontFeatures: [FontFeature.tabularFigures()]);
}
