import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../models/journey.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'journey/facility_chip.dart';
import 'journey/step_card.dart';
import 'step_icon_badge.dart';

String _stationLabel(String name) => name.endsWith('역') ? name : '$name역';

/// 지상 진입 → 승차(칸번호) → 환승/도착 순서의 세로 타임라인.
///
/// 각 단계를 [TimelineStepCard]로 감싸 아이콘 배지·제목·소요시간·상세정보의
/// 시각 계층을 분리한다(디자인기획팀 개선안 반영 — 문장 나열 → 카드+칩).
class JourneyTimeline extends StatelessWidget {
  final Journey journey;
  const JourneyTimeline({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    // (배지, 제목, 소요분, 상세위젯) 튜플로 먼저 모은 뒤 마지막 항목에만
    // isLast를 매겨 TimelineStepCard를 한 번씩만 생성한다.
    final steps = <(StepIconBadge, String, int?, Widget, Color?)>[
      (
        StepIconBadge.entrance(context, isExit: false),
        '${_stationLabel(journey.enterStation)} 진입 · 지상 → 지하',
        null,
        _ElevatorChips(journey.enterElevators),
        null,
      ),
      for (final leg in journey.legs) ...[
        (
          StepIconBadge.ride(leg.line),
          '${leg.line}호선 승차 · ${leg.fromName} → ${leg.toName}',
          leg.minutes,
          _CarChips(leg.cars),
          // 승차 구간 아래 연결선만 노선 색으로 — 네이버지도처럼 "지금 타고
          // 있는 노선"이 세로선 색으로 바로 보이게 한다.
          AppColors.lineColor(leg.line),
        ),
        (
          leg.isTransfer
              ? StepIconBadge.transfer(context)
              : StepIconBadge.entrance(context, isExit: true),
          leg.isTransfer
              ? '${_stationLabel(leg.toName)} 환승'
              : '${_stationLabel(leg.toName)} 도착 · 지하 → 지상',
          null,
          _ElevatorChips(leg.arrivalElevators),
          null,
        ),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          TimelineStepCard(
            badge: steps[i].$1,
            title: steps[i].$2,
            durationMinutes: steps[i].$3,
            detail: steps[i].$4,
            isLast: i == steps.length - 1,
            lineColor: steps[i].$5,
          ),
      ],
    );
  }
}

class _ElevatorChips extends StatelessWidget {
  final List<Facility> elevators;
  const _ElevatorChips(this.elevators);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    if (elevators.isEmpty) {
      return Text('엘리베이터 위치 정보 없음',
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant));
    }
    return Wrap(
      spacing: AppSpacing.space8,
      runSpacing: AppSpacing.space8,
      children: [
        for (final e in elevators.take(4))
          FacilityChip(
            icon: Icons.elevator,
            title: e.exit.isNotEmpty ? '출구 ${e.exit}' : '엘리베이터',
            subtitle: e.detail,
          ),
      ],
    );
  }
}

class _CarChips extends StatelessWidget {
  final List<CarCandidate> cars;
  const _CarChips(this.cars);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    if (cars.isEmpty) {
      return Text('도착역 엘리베이터 최단 칸 정보 없음',
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant));
    }
    return Wrap(
      spacing: AppSpacing.space8,
      runSpacing: AppSpacing.space8,
      children: [
        for (final c in cars.take(6))
          FacilityChip(
            icon: Icons.door_front_door,
            title: '${c.door}번 칸',
            subtitle: c.toward,
            accent: cs.secondary,
          ),
      ],
    );
  }
}
