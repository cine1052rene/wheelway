import 'package:flutter/material.dart';

/// 구간 소요시간 표기. 문장 속에 묻히지 않게 굵게 강조하되, 예전처럼
/// 진한 색 알약(pill) 배경을 채우지 않는다 — 네이버지도 참고: 소요시간은
/// 굵은 글자만으로 충분히 눈에 띄고, 배경색은 진짜 색이 필요한 곳(호선
/// 배지·미니바)에 아껴 써야 화면이 산만해지지 않는다(사용자 피드백).
class DurationLozenge extends StatelessWidget {
  final int minutes;
  final Color? color;
  const DurationLozenge({super.key, required this.minutes, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      '$minutes분',
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: color ?? cs.primary, fontWeight: FontWeight.w800),
    );
  }
}
