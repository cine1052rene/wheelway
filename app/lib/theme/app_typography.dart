import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 타이포그래피 토큰.
///
/// 접근성 우선: 본문 최소 16sp. 폰트 크기 단위는 sp(논리 픽셀 + 시스템 글꼴
/// 배율)이며, 사용자의 OS 글꼴 확대 설정을 존중하기 위해 배율을 임의로
/// 제한(clamp)하지 않는다. 굵기는 저시력 가독성을 위해 본문도 w500 이상 사용.
class AppTypography {
  AppTypography._();

  static const String? fontFamily = null; // 시스템 기본(가독성 검증된 Roboto/한글 폰트)

  static const TextTheme textTheme = TextTheme(
    // 화면 타이틀
    headlineMedium: TextStyle(
      fontSize: 26,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    // 섹션 제목
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    // 카드 제목 / 역명
    titleMedium: TextStyle(
      fontSize: 18,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    // 본문 (최소 16)
    bodyLarge: TextStyle(
      fontSize: 17,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    // 보조 설명(주의: 15 미만으로 내리지 말 것)
    bodySmall: TextStyle(
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    // 버튼 라벨
    labelLarge: TextStyle(
      fontSize: 17,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
  );
}
