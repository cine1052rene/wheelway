import 'package:flutter/material.dart';

/// 스크롤이 끝에 닿을 때 화면이 눌린 듯 늘어나 보이는 안드로이드 12+
/// "스트레치" 오버스크롤 효과를 앱 전역에서 제거한다(사용자 피드백 —
/// 거슬림). 글로우(구버전 효과)도 함께 제거해 스크롤 끝은 그냥 멈추게 한다.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
