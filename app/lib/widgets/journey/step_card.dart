import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../step_icon_badge.dart';
import '../duration_lozenge.dart';

/// 타임라인 한 단계 = [연결선+아이콘 배지] + [카드(제목/부제/소요시간)].
///
/// 기존엔 아이콘·제목·상세정보가 전부 같은 굵기의 문장으로 나열돼 텍스트
/// 위주로 느껴졌다. 제목(bodyLarge, 굵게)과 상세(child, 칩/배지)를 카드
/// 안에서 분리해 한눈에 훑을 수 있는 시각 계층을 만든다.
/// 카드 스타일은 앱 전반의 플랫+테두리 카드와 통일(그림자 대신 outline).
class TimelineStepCard extends StatelessWidget {
  final StepIconBadge badge;
  final String title;
  final int? durationMinutes;
  final Widget detail;
  final bool isLast;
  final Color? lineColor;

  const TimelineStepCard({
    super.key,
    required this.badge,
    required this.title,
    this.durationMinutes,
    required this.detail,
    this.isLast = false,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 44,
                    bottom: 0,
                    // 네이버지도처럼 구간 연결선을 해당 노선 색으로 표시해
                    // "지금 몇 호선을 타고 있는지" 세로선만 봐도 알 수 있게 함.
                    child: Container(width: 3, color: lineColor ?? cs.primaryContainer),
                  ),
                badge,
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: t.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (durationMinutes != null) ...[
                          const SizedBox(width: AppSpacing.space8),
                          DurationLozenge(
                              minutes: durationMinutes!, color: lineColor),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    detail,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
