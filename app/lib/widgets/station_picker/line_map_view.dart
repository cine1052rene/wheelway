import 'package:flutter/material.dart';
import '../../data/lines.dart';
import '../../data/stations.dart';
import '../../models/station.dart';
import '../../services/line_topology.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// 전체 노선도에서 역을 직접 짚어 출발/도착역을 고르는 뷰.
///
/// ⚠️ 역 좌표(위경도) 데이터가 없어 실제 지하철 노선도처럼 정확한 굴곡·
/// 교차를 그린 지도는 아니다 — 노선별 역 순서(위상)를 살린 **개략적
/// 노선도**로, 역 칩이 화면 너비를 채우며 아래로 줄바꿈돼(Wrap) 세로
/// 스크롤만으로 노선 전체를 훑을 수 있다. 정확한 지리 배치가 필요하면
/// 역 좌표 데이터 확보가 별도로 필요하다(추후 과제).
class LineMapView extends StatelessWidget {
  final String? selectedLine;
  final ValueChanged<Station> onSelected;
  final ScrollController? scrollController;

  const LineMapView({
    super.key,
    required this.selectedLine,
    required this.onSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final byId = {for (final s in kStations) s.id: s};
    final lines = selectedLine != null ? [selectedLine!] : kAvailableLines;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      itemCount: lines.length,
      itemBuilder: (_, i) {
        final line = lines[i];
        final chains = LineTopology.chainsFor(line);
        if (chains.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.lineColor(line),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onLineColor(line),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Text('$line호선', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),
              for (final chain in chains) _LineChainRow(
                line: line,
                chain: chain,
                byId: byId,
                onSelected: onSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 노선 하나의 역 순서를 줄바꿈되는 칩 그리드로 보여준다.
///
/// 예전엔 한 줄짜리 가로 스크롤(48dp 높이)이라, 화면 아래는 텅 비어있는데
/// 역을 보려면 옆으로 계속 스크롤해야 했다(사용자 피드백: "빈 공간 두고
/// 횡스크롤 할 필요가 있을까"). `Wrap`으로 바꿔 화면 너비를 다 채우며
/// 아래로 흐르게 해, 세로 스크롤 한 번으로 노선 전체 역이 한눈에 보이게
/// 했다.
class _LineChainRow extends StatelessWidget {
  final String line;
  final List<String> chain;
  final Map<String, Station> byId;
  final ValueChanged<Station> onSelected;

  const _LineChainRow({
    required this.line,
    required this.chain,
    required this.byId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = AppColors.lineColor(line);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: AppSpacing.space8,
        children: [
          for (int idx = 0; idx < chain.length; idx++) ...[
            if (idx > 0)
              Icon(Icons.chevron_right, size: 16, color: lineColor),
            if (byId[chain[idx]] case final station?)
              _StationDot(
                station: station,
                line: line,
                onTap: () => onSelected(station),
              ),
          ],
        ],
      ),
    );
  }
}

class _StationDot extends StatelessWidget {
  final Station station;
  final String line;
  final VoidCallback onTap;
  const _StationDot(
      {required this.station, required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // ⚠️ Wrap 안에 InkWell+Container(alignment 포함)를 IntrinsicWidth 없이
    // 넣으면 Wrap의 무제한 폭 측정 때문에 칩이 한 줄 전체로 늘어나는 렌더링
    // 버그가 있다(이 프로젝트에서 반복 발생 — MEMORY.md에 기록된 함정).
    // 항상 IntrinsicWidth로 감쌀 것.
    return IntrinsicWidth(
      child: Semantics(
        label: '${station.name}역 선택',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: AppSpacing.touchMin,
              minHeight: AppSpacing.touchMin,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: AppColors.lineColor(line), width: 1.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            ),
            alignment: Alignment.center,
            child: Text(
              station.name,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
      ),
    );
  }
}
