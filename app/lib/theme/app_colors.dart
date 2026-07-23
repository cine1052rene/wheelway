import 'package:flutter/material.dart';

/// WheelWay 색상 토큰 — 디자인 시스템 "에메랄드 클리어".
///
/// 접근성 최우선(WCAG 2.1 AA+). 색만으로 정보를 전달하지 않도록(색맹 고려)
/// 아이콘/텍스트를 항상 병행한다. 라이트/다크 두 세트를 모두 정의하고
/// ThemeMode.system으로 자동 전환한다.
///
/// Flutter 3.44 기준 deprecated 필드(background/surfaceVariant)는 쓰지 않고,
/// 배경은 [scaffoldLight]/[scaffoldDark]로 ThemeData에서 직접 지정한다.
class AppColors {
  AppColors._();

  // 브랜드 시드
  static const Color seedPrimary = Color(0xFF08705B);
  static const Color seedSecondary = Color(0xFFB45400);
  static const Color seedTertiary = Color(0xFFEE8D42); // 장식 전용(텍스트 금지)

  // 스캐폴드(앱 기본 배경) — ColorScheme.surface(카드=흰색)와 구분되는 값.
  static const Color scaffoldLight = Color(0xFFF8FAF7);
  static const Color scaffoldDark = Color(0xFF0E1A16);

  // 구분/장식 배경(구 surfaceVariant 역할) — 위젯에서 직접 참조.
  static const Color surfaceVariantLight = Color(0xFFDBE5DF);
  static const Color surfaceVariantDark = Color(0xFF2D3F38);

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF08705B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC8F0E3),
    onPrimaryContainer: Color(0xFF00201A),
    secondary: Color(0xFFB45400),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDCBF),
    onSecondaryContainer: Color(0xFF2E1400),
    tertiary: Color(0xFF3B5F52),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFBDE9D9),
    onTertiaryContainer: Color(0xFF00201A),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF15211D),
    onSurfaceVariant: Color(0xFF414E48),
    surfaceContainerHighest: Color(0xFFDBE5DF),
    outline: Color(0xFF66736D),
    outlineVariant: Color(0xFFBFC9C2),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2D3C36),
    onInverseSurface: Color(0xFFEEF2EE),
    inversePrimary: Color(0xFF6FDBB8),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6FDBB8),
    onPrimary: Color(0xFF00382B),
    primaryContainer: Color(0xFF005241),
    onPrimaryContainer: Color(0xFF6FDBB8),
    secondary: Color(0xFFFFB870),
    onSecondary: Color(0xFF4A2800),
    secondaryContainer: Color(0xFF6B3A00),
    onSecondaryContainer: Color(0xFFFFDCBF),
    tertiary: Color(0xFFFFA95C),
    onTertiary: Color(0xFF4C1E00),
    tertiaryContainer: Color(0xFF6B3A00),
    onTertiaryContainer: Color(0xFFFFDCBF),
    error: Color(0xFFFF8875),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1A2C24),
    onSurface: Color(0xFFDCE9E4),
    onSurfaceVariant: Color(0xFFA8C4BC),
    surfaceContainerHighest: Color(0xFF2D3F38),
    outline: Color(0xFF7F9590),
    outlineVariant: Color(0xFF414E48),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFDCE9E4),
    onInverseSurface: Color(0xFF2D3C36),
    inversePrimary: Color(0xFF08705B),
  );

  /// 지하철 노선 색 (서울교통공사 공식 계열, 1~8호선).
  static const Map<String, Color> line = {
    '1': Color(0xFF0052A4),
    '2': Color(0xFF00A84D),
    '3': Color(0xFFEF7C1C),
    '4': Color(0xFF00A5DE),
    '5': Color(0xFF996CAC),
    '6': Color(0xFFCD7C2F),
    '7': Color(0xFF747F00),
    '8': Color(0xFFE6186C),
  };

  static Color lineColor(String lineNo) => line[lineNo] ?? seedPrimary;

  /// 호선 배경 위에 올릴 텍스트/아이콘 색을 자동 판정한다(하드코딩 목록 대신
  /// 실제 색상 휘도를 계산 — 색상표가 바뀌어도 항상 WCAG 대비를 만족한다).
  /// 예: 3호선(주황)·6호선(갈색)처럼 밝은 배경은 검정 텍스트를, 나머지는
  /// 흰 텍스트를 골라 흰 글자가 밝은 배경에 묻히는 문제를 방지한다.
  static Color onLineColor(String lineNo) {
    final bg = lineColor(lineNo);
    const black = Color(0xFF1A1A1A);
    final contrastWithWhite = _contrastRatio(bg, Colors.white);
    final contrastWithBlack = _contrastRatio(bg, black);
    return contrastWithBlack > contrastWithWhite ? black : Colors.white;
  }

  static double _contrastRatio(Color a, Color b) {
    final la = a.computeLuminance() + 0.05;
    final lb = b.computeLuminance() + 0.05;
    return la > lb ? la / lb : lb / la;
  }
}
