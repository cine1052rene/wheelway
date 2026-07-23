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

  static const _rows = [['1', '2', '3', '4'], ['5', '6', '7', '8']];

  @override
  Widget build(BuildContext context) {
    // GridView.count(childAspectRatio:1)는 셀을 화면 폭 4등분만큼 늘려
    // 64dp 목표보다 훨씬 크게(~89dp) 렌더링됐다(빈 공간 낭비 원인).
    // 고정 64×64 셀을 두 줄 Row로 배치해 실제 필요한 크기만 차지하게 한다.
    return Column(
      children: [
        for (final row in _rows) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final line in row)
                _LineCell(
                  line: line,
                  isSelected: selectedLine == line,
                  onTap: () =>
                      onLineSelected(selectedLine == line ? null : line),
                ),
            ],
          ),
          if (row != _rows.last) const SizedBox(height: AppSpacing.space8),
        ],
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
