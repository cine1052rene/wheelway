import 'package:flutter/material.dart';
import '../../models/journey.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// 경로 결과 최상단 요약 — 총 소요시간을 큰 숫자로 강조하고 환승 횟수를
/// 구분선 옆에 병기해, 타임라인을 읽기 전에 핵심 수치부터 스캔되게 한다.
/// 네이버지도 길찾기 결과 상단의 "구간별 색상 미니바"를 참고해, 숫자만으론
/// 안 보이던 "어느 노선이 이동시간의 대부분을 차지하는지"를 한눈에 보여준다.
class RouteSummaryCard extends StatelessWidget {
  final String profileLabel;
  final int totalMinutes;
  final int transferCount;
  final List<JourneyLeg> legs;

  const RouteSummaryCard({
    super.key,
    required this.profileLabel,
    required this.totalMinutes,
    required this.transferCount,
    this.legs = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // 네이버지도 참고 — 예전엔 이 카드 전체가 진한 색으로 채워져 있어
    // 화면에 들어오자마자 색상 블록이 하나 더 생기는 느낌이었다(사용자
    // 피드백: "색상박스가 너무 많아 산만하다"). 배경은 중립(흰색+테두리)로
    // 비우고, 색은 진짜 정보를 담은 미니바에만 쓴다.
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profileLabel,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$totalMinutes',
                        style: t.headlineMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text('분',
                          style:
                              t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.space24),
              Container(
                width: 1,
                height: 40,
                color: cs.outlineVariant,
              ),
              const SizedBox(width: AppSpacing.space24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('환승',
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  Text(
                    transferCount == 0 ? '없음' : '$transferCount회',
                    style: t.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (legs.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space16),
            _RouteMiniBar(legs: legs),
          ],
        ],
      ),
    );
  }
}

/// 승차 구간을 노선 색으로 비례 배분한 가로 미니바. 구간 위엔 소요분,
/// 아래엔 노선명을 병기(네이버 스타일) — 좁은 구간은 자동 축소해 겹치지
/// 않게 한다. 환승 지점은 흰색 여백으로만 구분(실측 도보시간 데이터가
/// 없어 임의로 만들지 않음 — 실측 전 데이터를 만들어 쓰지 않는다는 원칙).
class _RouteMiniBar extends StatelessWidget {
  final List<JourneyLeg> legs;
  const _RouteMiniBar({required this.legs});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rideLegs = legs.where((l) => l.minutes > 0).toList();
    if (rideLegs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < rideLegs.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                flex: rideLegs[i].minutes,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${rideLegs[i].minutes}분',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                for (int i = 0; i < rideLegs.length; i++) ...[
                  if (i > 0) Container(width: 3, color: cs.surface),
                  Expanded(
                    flex: rideLegs[i].minutes,
                    child: Container(color: AppColors.lineColor(rideLegs[i].line)),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            for (int i = 0; i < rideLegs.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                flex: rideLegs[i].minutes,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${rideLegs[i].line}호선',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
