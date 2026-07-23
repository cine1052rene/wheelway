import 'package:flutter/material.dart';
import '../data/stations.dart';
import '../models/station.dart';
import '../theme/app_spacing.dart';
import 'station_picker/grouped_station_list.dart';
import 'station_picker/line_filter_grid.dart';
import 'station_picker/line_map_view.dart';

/// 역 선택 바텀시트(검색 + 호선 필터 + 목록/노선도 전환). 선택한 [Station]을
/// 반환한다.
///
/// 검색바·호선 필터는 고정, 아래 영역만 "목록"(가나다순, 독립 스크롤) 또는
/// "노선도"(노선을 가로로 훑으며 역을 직접 탭)로 전환된다.
Future<Station?> showStationPicker(BuildContext context, {String? title}) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.6, 0.92],
      builder: (_, scrollController) => _StationPickerSheet(
        title: title ?? '역 선택',
        scrollController: scrollController,
      ),
    ),
  );
}

enum _ViewMode { list, map }

class _StationPickerSheet extends StatefulWidget {
  final String title;
  final ScrollController scrollController;
  const _StationPickerSheet(
      {required this.title, required this.scrollController});

  @override
  State<_StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<_StationPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';
  String? _selectedLine;
  _ViewMode _mode = _ViewMode.list;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Station> get _filtered {
    final q = _query.trim();
    return kStations.where((s) {
      final matchQuery = q.isEmpty || s.name.contains(q);
      final matchLine = _selectedLine == null || s.lines.contains(_selectedLine);
      return matchQuery && matchLine;
    }).toList();
  }

  void _select(Station s) => Navigator.pop(context, s);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final list = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16,
                  AppSpacing.space12, AppSpacing.space16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(widget.title, style: t.titleLarge)),
                      SegmentedButton<_ViewMode>(
                        segments: const [
                          ButtonSegment(
                              value: _ViewMode.list,
                              icon: Icon(Icons.list, size: 18),
                              label: Text('목록')),
                          ButtonSegment(
                              value: _ViewMode.map,
                              icon: Icon(Icons.route, size: 18),
                              label: Text('노선도')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (s) =>
                            setState(() => _mode = s.first),
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  if (_mode == _ViewMode.list)
                    TextField(
                      controller: _controller,
                      style: t.bodyLarge,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: '역명 검색 (예: 강남)',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  if (_mode == _ViewMode.map)
                    Text(
                      '노선을 고르고 가로로 훑으며 역을 탭해 선택하세요.',
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  const SizedBox(height: AppSpacing.space12),
                  LineFilterGrid(
                    selectedLine: _selectedLine,
                    onLineSelected: (line) =>
                        setState(() => _selectedLine = line),
                  ),
                ],
              ),
            ),
            const Divider(height: AppSpacing.space16),
            Expanded(
              child: _mode == _ViewMode.map
                  ? LineMapView(
                      selectedLine: _selectedLine,
                      onSelected: _select,
                      scrollController: widget.scrollController,
                    )
                  : (list.isEmpty
                      ? Center(
                          child: Text('검색 결과가 없습니다.',
                              style: t.bodyMedium
                                  ?.copyWith(color: cs.onSurfaceVariant)))
                      : GroupedStationList(
                          stations: list,
                          onSelected: _select,
                          scrollController: widget.scrollController,
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
