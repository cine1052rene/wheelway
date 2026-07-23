import 'package:flutter/material.dart';
import '../../models/station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// "노선도" 탭 전용 — 네이버지도 "지하철 전체노선도"를 참고한 세로형 노선
/// 다이어그램.
///
/// 역 선택 시트의 칩 그리드([LineMapView] — 빠르게 훑고 탭하는 용도)와는
/// **의도적으로 다른 스타일**을 쓴다(사용자 피드백: "노선도탭이 역선택
/// 창이랑 같을 필요는 없다"). 실제 지하철 노선도 포스터처럼 역을
/// "원(정차역)/이중원(환승역)"으로, 구간을 "이어진 색선"으로 그려서
/// 상자 나열이 아니라 하나의 "선"으로 인식되게 한다. 환승역 옆에는
/// 갈아탈 수 있는 다른 호선의 작은 색점을 함께 표시한다(실제 노선도의
/// 환승 표기 관례).
class SubwayLineDiagram extends StatelessWidget {
  final String line;
  final List<List<String>> chains;
  final Map<String, Station> byId;
  final ValueChanged<Station> onSelected;

  const SubwayLineDiagram({
    super.key,
    required this.line,
    required this.chains,
    required this.byId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = AppColors.lineColor(line);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int c = 0; c < chains.length; c++) ...[
          if (c > 0) const SizedBox(height: AppSpacing.space16),
          for (int i = 0; i < chains[c].length; i++)
            if (byId[chains[c][i]] case final station?)
              _StationNode(
                station: station,
                currentLine: line,
                lineColor: lineColor,
                isLast: i == chains[c].length - 1,
                onTap: () => onSelected(station),
              ),
        ],
      ],
    );
  }
}

class _StationNode extends StatelessWidget {
  final Station station;
  final String currentLine;
  final Color lineColor;
  final bool isLast;
  final VoidCallback onTap;

  const _StationNode({
    required this.station,
    required this.currentLine,
    required this.lineColor,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final isTransfer = station.lines.length > 1;
    final otherLines = station.lines.where((l) => l != currentLine).toList();

    return Semantics(
      label: '${station.name}역 선택${isTransfer ? ", 환승역" : ""}',
      button: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isLast)
                      Positioned(
                        top: 20,
                        bottom: 0,
                        child: Container(width: 3, color: lineColor),
                      ),
                    Container(
                      width: isTransfer ? 16 : 11,
                      height: isTransfer ? 16 : 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isTransfer ? cs.surface : lineColor,
                        border: isTransfer
                            ? Border.all(color: lineColor, width: 3)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: Text(
                  station.name,
                  style: isTransfer
                      ? t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)
                      : t.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (otherLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final l in otherLines)
                        Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lineColor(l),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
