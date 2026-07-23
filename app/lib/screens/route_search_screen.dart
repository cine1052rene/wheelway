import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../widgets/page_header.dart';

/// 지름길 찾기 (핵심 화면). 현재는 뼈대 — 출발/도착 선택 UI와
/// 단계별 이동 타임라인 결과가 이후 단계에서 라우팅 엔진 포팅과 함께 붙는다.
class RouteSearchScreen extends StatelessWidget {
  const RouteSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
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
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction, color: cs.secondary),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(child: Text('준비 중', style: t.headlineSmall)),
                  ],
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  '출발·도착역 선택과 이동 타임라인 화면이 다음 단계에서 '
                  '연결됩니다. (네트워크 데이터·라우팅 엔진 포팅)',
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
