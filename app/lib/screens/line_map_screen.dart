import 'package:flutter/material.dart';
import '../models/station.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/station_picker/line_filter_grid.dart';
import '../widgets/station_picker/line_map_view.dart';

/// 전체 지하철 노선도 — "지름길 안내 앱"인데도 정작 노선 전체를 훑어볼
/// 화면이 없다는 지적(사용자 피드백, 네이버지도 참고)으로 신설.
///
/// 역 좌표(위경도) 데이터가 없어 실제 지도처럼 정확한 굴곡은 그리지 않고,
/// 노선별 역 순서(위상)를 살린 개략적 노선도로 보여준다([LineMapView] 재사용
/// — 기존엔 역 선택 바텀시트 안에서만 쓰였는데, "그냥 훑어보기"용으로 별도
/// 진입점을 만든 것). 역을 탭하면 출발/도착역으로 바로 지정해 지름길 찾기로
/// 이동할 수 있다.
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
          child: LineMapView(
            selectedLine: _selectedLine,
            onSelected: _onStationTap,
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
