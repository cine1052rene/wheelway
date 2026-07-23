import 'package:flutter/material.dart';

/// 엘리베이터 위치·칸번호 정보를 표시하는 공용 칩.
///
/// 기존엔 엘리베이터는 줄글(Text), 칸번호는 Wrap 칩으로 시각 언어가
/// 달랐다(디자인기획팀 지적). 이 위젯 하나로 통일해 굵은 핵심 정보(제목)와
/// 옅은 보조 정보(부제)를 같은 카드 안에서 항상 같은 방식으로 보여준다.
class FacilityChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color background;
  final Color foreground;

  const FacilityChip({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: t.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
