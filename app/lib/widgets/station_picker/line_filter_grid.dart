import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// 역 선택 시트의 호선 필터 — 2×4 그리드, 큰 터치 타깃(64dp)으로 교통약자가
/// 정확히 탭하기 쉽게 한다. 가나다순 240역 스크롤 대신 노선으로 즉시 좁힌다.
class LineFilterGrid extends StatelessWidget {
  final String? selectedLine; // null = 전체
  final ValueChanged<String?> onLineSelected;

  const LineFilterGrid({
    super.key,
    required this.selectedLine,
    required this.onLineSelected,
  });

  static const _lines = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.space8,
          crossAxisSpacing: AppSpacing.space8,
          childAspectRatio: 1,
          children: [
            for (final line in _lines)
              _LineCell(
                line: line,
                isSelected: selectedLine == line,
                onTap: () =>
                    onLineSelected(selectedLine == line ? null : line),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => onLineSelected(null),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSpacing.touchMin),
              side: BorderSide(
                color: selectedLine == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: const Text('전체 노선'),
          ),
        ),
      ],
    );
  }
}

class _LineCell extends StatelessWidget {
  final String line;
  final bool isSelected;
  final VoidCallback onTap;
  const _LineCell(
      {required this.line, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.lineColor(line);
    final fg = AppColors.onLineColor(line);
    return Semantics(
      label: '$line호선 필터${isSelected ? " 선택됨" : ""}',
      button: true,
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            child: Container(
              constraints: const BoxConstraints(
                minWidth: AppSpacing.space64,
                minHeight: AppSpacing.space64,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$line호선',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: fg, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
