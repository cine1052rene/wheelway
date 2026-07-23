import 'package:flutter/material.dart';
import '../../data/lines.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// 역 선택 시트의 호선 필터.
///
/// 노선 목록은 하드코딩("1~8호선")이 아니라 [kAvailableLines](실제 데이터
/// 기준)에서 가져온다 — 9호선·공항철도·GTX 등이 데이터에 추가되면 이
/// 위젯은 코드 수정 없이 자동으로 늘어난다. 노선 수가 계속 늘어날 걸
/// 감안해 셀 크기는 접근성 최소 기준인 48dp로 줄이고(WCAG 2.5.5 — 이보다
/// 작게는 만들지 않는다), 고정 행 대신 [Wrap]으로 자동 줄바꿈한다.
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
    return Column(
      children: [
        Wrap(
          spacing: AppSpacing.space8,
          runSpacing: AppSpacing.space8,
          children: [
            for (final line in kAvailableLines)
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
    // IntrinsicWidth로 감싸지 않으면 Wrap이 측정 시 자식에게 무제한 너비를
    // 줄 때 Material/Container(alignment 포함)가 가로 전체로 늘어나
    // 셀 하나가 한 줄을 다 차지하는 렌더링 오버플로가 발생했다(실기기 확인).
    return IntrinsicWidth(
      child: Semantics(
        label: '$line호선 필터${isSelected ? " 선택됨" : ""}',
        button: true,
        child: AnimatedScale(
          scale: isSelected ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
              child: Container(
                // 숫자 노선(1~8)은 정사각형 48dp, GTX-A·공항철도처럼 긴
                // 노선명은 내용에 맞춰 폭만 넓어지는 알약형(높이는 48dp 고정).
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.touchMin,
                  minHeight: AppSpacing.touchMin,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
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
    );
  }
}
