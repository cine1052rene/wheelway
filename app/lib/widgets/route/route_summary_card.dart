import 'package:flutter/material.dart';
import '../../models/journey.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// 경로 결과 최상단 요약 — 총 소요시간과 환승 횟수를 한 줄로, 노선별
/// 색상 미니바를 그 아래 한 줄로 압축해 보여준다.
///
/// **세로 공간 압축(사용자 피드백)**: "스크롤 없이 최대한의 정보를 보고
/// 싶다"는 요청으로, 기존엔 (프로필 라벨+시간/환승) 줄과 (분 라벨/바/
/// 노선명 라벨) 3줄짜리 미니바를 합쳐 총 4줄을 썼던 걸, 정보 손실 없이
/// 2줄로 줄였다 — 프로필은 상단 선택바에 이미 보이니 여기서 반복 표시하지
/// 않고, 미니바는 분·노선명을 막대 안에 함께 새겨(embedded label) 위아래
/// 라벨 줄을 없앴다.
class RouteSummaryCard extends StatelessWidget {
  final int totalMinutes;
  final int transferCount;
  final List<JourneyLeg> legs;

  const RouteSummaryCard({
    super.key,
    required this.totalMinutes,
    required this.transferCount,
    this.legs = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16, vertical: AppSpacing.space12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalMinutes',
                style: t.headlineSmall
                    ?.copyWith(color: cs.primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 2),
              Text('분', style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: AppSpacing.space12),
              Icon(Icons.sync_alt, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 2),
              Text(
                transferCount == 0 ? '환승 없음' : '환승 $transferCount회',
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          if (legs.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space8),
            _RouteMiniBar(legs: legs),
          ],
        ],
      ),
    );
  }
}

/// 승차 구간을 노선 색으로 비례 배분한 가로 미니바 한 줄. "N호선 N분"을
/// 막대 안에 직접 새겨 별도 라벨 줄을 없앴다(좁은 구간은 자동 축소).
/// 환승 지점은 흰 여백으로만 구분(실측 도보시간 데이터가 없어 임의로
/// 만들지 않음 — 실측 전 데이터를 만들어 쓰지 않는다는 원칙).
class _RouteMiniBar extends StatelessWidget {
  final List<JourneyLeg> legs;
  const _RouteMiniBar({required this.legs});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rideLegs = legs.where((l) => l.minutes > 0).toList();
    if (rideLegs.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            for (int i = 0; i < rideLegs.length; i++) ...[
              if (i > 0) Container(width: 2, color: cs.surface),
              Expanded(
                flex: rideLegs[i].minutes,
                child: Container(
                  color: AppColors.lineColor(rideLegs[i].line),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                      child: Text(
                        '${rideLegs[i].line}호선 ${rideLegs[i].minutes}분',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onLineColor(rideLegs[i].line),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
