import 'package:flutter/material.dart';
import '../data/lines.dart';
import '../data/stations.dart';
import '../models/station.dart';
import '../services/line_topology.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/line_map/subway_line_diagram.dart';
import '../widgets/station_picker/line_filter_grid.dart';

/// 전체 지하철 노선도 — "지름길 안내 앱"인데도 정작 노선 전체를 훑어볼
/// 화면이 없다는 지적(사용자 피드백, 네이버지도 참고)으로 신설.
///
/// **역 선택 시트의 "노선도" 모드와 일부러 다른 화면**이다(사용자 피드백:
/// "노선도탭이 역선택창이랑 같을 필요는 없다"). 역 선택 시트는 빠르게
/// 훑고 탭하는 목적이라 칩 그리드([LineMapView])면 충분하지만, 이 탭은
/// "노선도를 본다"는 목적 자체가 다르므로 네이버지도의 지하철 전체노선도를
/// 참고해 [SubwayLineDiagram](역=원/환승역=이중원, 구간=이어진 색선)으로
/// 그린다. 역 좌표(위경도) 데이터가 없어 실제 지도처럼 정확한 굴곡은
/// 그리지 않고, 노선별 역 순서(위상)만 살린 개략적 다이어그램이다.
/// 역을 탭하면 출발/도착역으로 바로 지정해 지름길 찾기로 이동할 수 있다.
class LineMapScreen extends StatefulWidget {
  final ValueChanged<Station> onPickOrigin;
  final ValueChanged<Station> onPickDestination;

  const LineMapScreen({
    super.key,
    required this.onPickOrigin,
    required this.onPickDestination,
  });

  @override
  State<LineMapScreen> createState() => _LineMapScreenState();
}

class _LineMapScreenState extends State<LineMapScreen> {
  String? _selectedLine;

  void _onStationTap(Station station) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StationActionSheet(
        station: station,
        onPickOrigin: () {
          Navigator.pop(context);
          widget.onPickOrigin(station);
        },
        onPickDestination: () {
          Navigator.pop(context);
          widget.onPickDestination(station);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final byId = {for (final s in kStations) s.id: s};
    final lines = _selectedLine != null ? [_selectedLine!] : kAvailableLines;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
                AppSpacing.space12, AppSpacing.screenPadding, AppSpacing.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('노선도', style: t.headlineLarge),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  '역을 탭하면 출발/도착역으로 바로 지정할 수 있어요.',
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.space12),
                LineFilterGrid(
                  selectedLine: _selectedLine,
                  onLineSelected: (line) => setState(() => _selectedLine = line),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),
        Expanded(
          child: ListView.builder(
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
                        Text('$line호선', style: t.titleSmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    SubwayLineDiagram(
                      line: line,
                      chains: chains,
                      byId: byId,
                      onSelected: _onStationTap,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StationActionSheet extends StatelessWidget {
  final Station station;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;

  const _StationActionSheet({
    required this.station,
    required this.onPickOrigin,
    required this.onPickDestination,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.space16,
            AppSpacing.space12, AppSpacing.space16, AppSpacing.space16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.space12),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('${station.name}역', style: t.titleLarge),
            const SizedBox(height: AppSpacing.space8),
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                for (final line in station.lines)
                  Chip(
                    label: Text(line,
                        style: TextStyle(color: AppColors.onLineColor(line))),
                    backgroundColor: AppColors.lineColor(line),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickOrigin,
                    icon: const Icon(Icons.trip_origin),
                    label: const Text('출발역으로'),
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPickDestination,
                    icon: const Icon(Icons.flag),
                    label: const Text('도착역으로'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
