import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/page_header.dart';

/// 지름길 찾기 (핵심 화면). 현재는 뼈대 — 출발/도착 선택 UI와
/// 단계별 이동 타임라인 결과가 이후 단계에서 라우팅 엔진 포팅과 함께 붙는다.
class RouteSearchScreen extends StatelessWidget {
  const RouteSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      children: [
        const PageHeader(
          eyebrow: '교통약자 지름길',
          title: '지름길 찾기',
          description: '지상 진입부터 승차 칸, 환승, 지상 진출까지 '
              '가장 빠르고 안전한 이동 순서를 안내합니다.',
        ),
        Padding(
          padding: AppSpacing.screenInsets,
          child: Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.construction, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('준비 중', style: t.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '출발·도착역 선택과 이동 타임라인 화면이 다음 단계에서 '
                  '연결됩니다. (네트워크 데이터·라우팅 엔진 포팅)',
                  style: t.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
