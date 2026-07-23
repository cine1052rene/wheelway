import 'package:flutter/material.dart';

/// WheelWay 색상 토큰.
///
/// 접근성 최우선: 모든 텍스트/배경 조합은 WCAG AA(본문 4.5:1 이상)를 목표로
/// 골랐다. 노란색처럼 흰 배경에서 명암비가 떨어지는 색은 상태 표시에 쓰지 않는다.
/// 색만으로 정보를 전달하지 않도록(색맹 고려) 아이콘/텍스트를 항상 함께 쓴다.
class AppColors {
  AppColors._();

  // 브랜드
  static const Color primary = Color(0xFF00695C); // deep teal, 흰 배경 대비 5.9:1
  static const Color primaryDark = Color(0xFF004D40);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 배경/표면
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF4F6F8);
  static const Color surfaceAlt = Color(0xFFE9EDF1);
  static const Color outline = Color(0xFFC4CAD0);

  // 텍스트 (near-black 우선, 회색은 최소 대비 확보한 값만)
  static const Color textPrimary = Color(0xFF1A1C1E); // 15.8:1
  static const Color textSecondary = Color(0xFF44474A); // 8.9:1
  static const Color textOnColor = Color(0xFFFFFFFF);

  // 의미색 (이용 가능 / 주의·우회 / 차단·불가)
  static const Color available = Color(0xFF1B7F3B); // 접근성 녹색, 4.9:1
  static const Color availableBg = Color(0xFFE3F4E9);
  static const Color warning = Color(0xFFB25000); // 주황(노랑 대신), 4.6:1
  static const Color warningBg = Color(0xFFFBEDE3);
  static const Color blocked = Color(0xFFB3261E); // 4.9:1
  static const Color blockedBg = Color(0xFFFAE7E6);

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

  static Color lineColor(String lineNo) => line[lineNo] ?? primary;
}
