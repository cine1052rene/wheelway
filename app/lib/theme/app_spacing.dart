import 'package:flutter/widgets.dart';

/// 간격·크기·반경 토큰 ("에메랄드 클리어").
///
/// 접근성 핵심 수치를 단일 관리한다. 특히 [touchMin](48dp)은 모든 탭 가능한
/// 위젯에서 반드시 지킬 것(WCAG 2.5.5 / Material 최소 기준).
class AppSpacing {
  AppSpacing._();

  // 간격 스케일
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  static const double space56 = 56;
  static const double space64 = 64;

  // 반경 토큰
  static const double radiusXs = 4;
  static const double radiusChip = 8;
  static const double radiusButton = 12;
  static const double radiusInput = 12;
  static const double radiusCard = 16;
  static const double radiusSheet = 20; // 바텀시트/다이얼로그
  static const double radiusFull = 999;

  // 터치 타깃/컴포넌트 높이
  static const double touchMin = 48;
  static const double touchPreferred = 56;
  static const double navBarHeight = 64;
  static const double appBarHeight = 56;

  // 자주 쓰는 여백
  static const double screenPadding = 16;
  static const double cardPadding = 16;

  static const EdgeInsets screenInsets = EdgeInsets.all(screenPadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
}
