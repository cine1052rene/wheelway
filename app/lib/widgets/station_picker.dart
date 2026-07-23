import 'package:flutter/material.dart';
import '../data/stations.dart';
import '../models/station.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 역 선택 바텀시트(검색 가능). 선택한 [Station]을 반환한다.
Future<Station?> showStationPicker(BuildContext context, {String? title}) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StationPickerSheet(title: title ?? '역 선택'),
  );
}

class _StationPickerSheet extends StatefulWidget {
  final String title;
  const _StationPickerSheet({required this.title});

  @override
  State<_StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<_StationPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final q = _query.trim();
    final list = q.isEmpty
        ? kStations
        : kStations.where((s) => s.name.contains(q)).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 0,
                  AppSpacing.space16, AppSpacing.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: t.titleLarge),
                  const SizedBox(height: AppSpacing.space12),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    style: t.bodyLarge,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: '역명 검색 (예: 강남)',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text('검색 결과가 없습니다.',
                          style: t.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final s = list[i];
                        return ListTile(
                          minTileHeight: AppSpacing.touchMin,
                          leading: Wrap(
                            spacing: 2,
                            children: [
                              for (final ln in s.lines) _LineBadge(ln),
                            ],
                          ),
                          title: Text(s.name, style: t.titleMedium),
                          subtitle: s.hasFacility
                              ? null
                              : Text('편의시설 정보 없음',
                                  style: t.bodySmall
                                      ?.copyWith(color: cs.error)),
                          onTap: () => Navigator.pop(context, s),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineBadge extends StatelessWidget {
  final String line;
  const _LineBadge(this.line);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.lineColor(line),
        shape: BoxShape.circle,
      ),
      child: Text(line,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
