import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../models/journey.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

String _stationLabel(String name) => name.endsWith('역') ? name : '$name역';

/// 지상 진입 → 승차(칸번호) → 환승/도착 순서의 세로 타임라인.
class JourneyTimeline extends StatelessWidget {
  final Journey journey;
  const JourneyTimeline({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    final steps = <Widget>[];
    steps.add(_TimelineStep(
      icon: Icons.directions_walk,
      title: '${_stationLabel(journey.enterStation)} 진입 · 지상 → 지하',
      child: _ElevatorList(journey.enterElevators),
    ));
    for (final leg in journey.legs) {
      steps.add(_TimelineStep(
        icon: Icons.directions_subway,
        line: leg.line,
        title: '${leg.line}호선 승차 · ${leg.fromName} → ${leg.toName}',
        trailing: '${leg.minutes}분',
        child: _CarList(leg.cars),
      ));
      steps.add(_TimelineStep(
        icon: leg.isTransfer ? Icons.transfer_within_a_station : Icons.door_front_door,
        title: leg.isTransfer
            ? '${_stationLabel(leg.toName)} 환승'
            : '${_stationLabel(leg.toName)} 도착 · 지하 → 지상',
        child: _ElevatorList(leg.arrivalElevators),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(isLast: i == steps.length - 1, child: steps[i]),
      ],
    );
  }
}

/// 좌측 연결선 + 원형 인디케이터.
class _StepRow extends StatelessWidget {
  final Widget child;
  final bool isLast;
  const _StepRow({required this.child, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: cs.primaryContainer,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String? line;
  final String title;
  final String? trailing;
  final Widget child;
  const _TimelineStep({
    required this.icon,
    this.line,
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 22,
                color: line != null ? AppColors.lineColor(line!) : cs.primary),
            const SizedBox(width: AppSpacing.space8),
            Expanded(child: Text(title, style: t.titleMedium)),
            if (trailing != null)
              Text(trailing!,
                  style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        child,
      ],
    );
  }
}

class _ElevatorList extends StatelessWidget {
  final List<Facility> elevators;
  const _ElevatorList(this.elevators);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    if (elevators.isEmpty) {
      return Text('엘리베이터 위치 정보 없음',
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in elevators.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '🛗 ${[
                if (e.exit.isNotEmpty) '출구 ${e.exit}',
                if (e.detail.isNotEmpty) e.detail,
              ].join(' · ')}',
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class _CarList extends StatelessWidget {
  final List<CarCandidate> cars;
  const _CarList(this.cars);

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
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12, vertical: AppSpacing.space8),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            ),
            child: Text(
              '🚪 ${c.door}${c.toward.isNotEmpty ? ' · ${c.toward}' : ''}',
              style: t.labelMedium?.copyWith(color: cs.onSecondaryContainer),
            ),
          ),
      ],
    );
  }
}
