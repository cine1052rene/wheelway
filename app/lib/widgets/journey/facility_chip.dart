import 'package:flutter/material.dart';

/// 엘리베이터 위치·칸번호 정보를 표시하는 공용 칩.
///
/// 기존엔 엘리베이터는 줄글(Text), 칸번호는 Wrap 칩으로 시각 언어가
/// 달랐다(디자인기획팀 지적). 이 위젯 하나로 통일해 굵은 핵심 정보(제목)와
/// 옅은 보조 정보(부제)를 같은 카드 안에서 항상 같은 방식으로 보여준다.
///
/// **네이버지도 참고 — 색상박스 정리(사용자 피드백)**: 예전엔 칩마다
/// 배경을 진하게 채워서("색상박스가 너무 많다") 화면이 산만했다. 네이버는
/// 이런 보조 정보 칩을 전부 옅은 회색 테두리 스타일로 통일하고, 색은
/// 호선 배지·미니바처럼 진짜 중요한 곳에만 아껴 쓴다. 이 칩도 배경을 채우지
/// 않고 [accent]는 아이콘·제목 글자색에만 살짝 입힌다.
class FacilityChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accent;

  const FacilityChip({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final fg = accent ?? cs.onSurfaceVariant;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: t.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
