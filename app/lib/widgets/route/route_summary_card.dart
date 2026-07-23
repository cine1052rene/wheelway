import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// 경로 결과 최상단 요약 — 총 소요시간을 큰 숫자로 강조하고 환승 횟수를
/// 구분선 옆에 병기해, 타임라인을 읽기 전에 핵심 수치부터 스캔되게 한다.
class RouteSummaryCard extends StatelessWidget {
  final String profileLabel;
  final int totalMinutes;
  final int transferCount;

  const RouteSummaryCard({
    super.key,
    required this.profileLabel,
    required this.totalMinutes,
    required this.transferCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profileLabel,
                  style: t.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$totalMinutes',
                    style: t.headlineMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text('분',
                      style: t.bodyMedium
                          ?.copyWith(color: cs.onPrimaryContainer)),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.space24),
          Container(
            width: 1,
            height: 40,
            color: cs.onPrimaryContainer.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.space24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('환승',
                  style: t.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
              Text(
                transferCount == 0 ? '없음' : '$transferCount회',
                style: t.titleMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
