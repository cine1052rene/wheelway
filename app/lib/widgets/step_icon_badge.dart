import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 타임라인 각 단계의 역할(진입/승차/환승/도착)을 나타내는 원형 아이콘 배지.
///
/// 시각 배지는 40dp이지만 [Padding](4dp)으로 감싸 터치 영역을 48dp로
/// 보장한다(WCAG 2.5.5). 스크린리더용 [semanticLabel]을 필수로 받아
/// 시각 배지가 짧아져도 의미가 온전히 전달되게 한다.
class StepIconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String semanticLabel;

  const StepIconBadge({
    super.key,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    required this.semanticLabel,
  });

  /// 지상↔지하 진입/진출 엘리베이터 단계.
  factory StepIconBadge.entrance(BuildContext context, {required bool isExit}) {
    final cs = Theme.of(context).colorScheme;
    return StepIconBadge(
      icon: isExit ? Icons.exit_to_app : Icons.directions_walk,
      backgroundColor: cs.primary,
      iconColor: cs.onPrimary,
      semanticLabel: isExit ? '지상 진출' : '지상 진입',
    );
  }

  /// 노선 승차 단계 — 배경을 해당 호선 색으로.
  factory StepIconBadge.ride(String line) {
    return StepIconBadge(
      icon: Icons.directions_subway,
      backgroundColor: AppColors.lineColor(line),
      iconColor: AppColors.onLineColor(line),
      semanticLabel: '$line호선 승차',
    );
  }

  /// 환승 단계.
  factory StepIconBadge.transfer(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StepIconBadge(
      icon: Icons.transfer_within_a_station,
      backgroundColor: cs.secondaryContainer,
      iconColor: cs.onSecondaryContainer,
      semanticLabel: '환승',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
