import 'package:flutter/widgets.dart';

/// 간격·크기 토큰.
///
/// 접근성 핵심 수치는 여기서 단일 관리한다. 특히 [minTouchTarget]은
/// 모든 탭 가능한 위젯(버튼, 리스트 항목, 아이콘 버튼)에서 반드시 지켜야 한다
/// (교통약자 손 조작·저시력 고려, WCAG 2.5.5 / Material 최소 48dp 기준).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// 화면 좌우 기본 여백.
  static const double screenPadding = 16;

  /// 카드 내부 여백.
  static const double cardPadding = 16;

  /// 카드/버튼 모서리 둥글기.
  static const double radius = 14;
  static const double radiusSm = 10;

  /// 최소 터치 타깃(dp). 절대 이보다 작게 만들지 말 것.
  static const double minTouchTarget = 48;

  static const EdgeInsets screenInsets = EdgeInsets.all(screenPadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
}
