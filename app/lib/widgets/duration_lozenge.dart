import 'package:flutter/material.dart';

/// 구간 소요시간을 강조하는 알약 모양 배지. 문장 속에 묻히던 분(分) 표기를
/// 시각적으로 분리해 한눈에 스캔되게 한다.
class DurationLozenge extends StatelessWidget {
  final int minutes;
  const DurationLozenge({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$minutes분',
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
