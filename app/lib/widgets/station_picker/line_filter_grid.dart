import 'package:flutter/material.dart';
import '../../data/lines.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// 역 선택 시트의 호선 필터 — 원형 칩 한 줄, 가로 스크롤.
///
/// "전체" 선택은 별도 버튼이 아니라 맨 앞 칩으로 통합했다(기존엔 개별
/// 노선을 다시 탭해 해제하는 것과 기능이 겹쳐 존재감 없는 버튼이었음 —
/// 사용자 피드백). 노선 목록은 [kAvailableLines](실제 데이터 기준)에서
/// 가져와 9호선·공항철도·GTX 등이 추가되면 자동으로 늘어난다.
class LineFilterGrid extends StatelessWidget {
  final String? selectedLine; // null = 전체
  final ValueChanged<String?> onLineSelected;

  const LineFilterGrid({
    super.key,
    required this.selectedLine,
    required this.onLineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.touchMin,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kAvailableLines.length + 1,
        separatorBuilder: (_, i) => const SizedBox(width: AppSpacing.space8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _AllLinesCircle(
              isSelected: selectedLine == null,
              onTap: () => onLineSelected(null),
            );
          }
          final line = kAvailableLines[i - 1];
          return _LineCircle(
            line: line,
            isSelected: selectedLine == line,
            onTap: () =>
                onLineSelected(selectedLine == line ? null : line),
          );
        },
      ),
    );
  }
}

class _AllLinesCircle extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  const _AllLinesCircle({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isSelected ? cs.primary : cs.surfaceContainerHighest;
    final fg = isSelected ? cs.onPrimary : cs.onSurfaceVariant;
    return Semantics(
      label: '전체 노선${isSelected ? " 선택됨" : ""}',
      button: true,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppSpacing.touchMin,
            height: AppSpacing.touchMin,
            child: Icon(Icons.apps, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}

class _LineCircle extends StatelessWidget {
  final String line;
  final bool isSelected;
  final VoidCallback onTap;
  const _LineCircle(
      {required this.line, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.lineColor(line);
    final fg = AppColors.onLineColor(line);
    return Semantics(
      label: '$line호선 필터${isSelected ? " 선택됨" : ""}',
      button: true,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: bg,
          shape: CircleBorder(
            side: isSelected
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppSpacing.touchMin,
              height: AppSpacing.touchMin,
              child: Center(
                // 긴 노선명(GTX-A 등)도 원 안에 맞도록 자동 축소.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      line,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
