import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../models/facility.dart';
import '../services/wheelway_api.dart';
import '../widgets/station_access/facility_type_filter.dart';

/// 역 접근성 — 실제 엘리베이터/에스컬레이터 위치를 라이브 API로 조회.
/// 검색바+시설 필터는 상단 고정, 결과 목록만 독립 스크롤된다.
class StationAccessScreen extends StatefulWidget {
  const StationAccessScreen({super.key});

  @override
  State<StationAccessScreen> createState() => _StationAccessScreenState();
}

class _StationAccessScreenState extends State<StationAccessScreen> {
  final _api = WheelwayApi();
  final _controller = TextEditingController(text: '강남');
  bool _loading = false;
  String? _error;
  List<Facility> _results = const [];
  FacilityFilterType _filter = FacilityFilterType.all;

  @override
  void dispose() {
    _controller.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.fetchStationFacilities(name);
      setState(() => _results = list);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Facility> get _filteredResults {
    switch (_filter) {
      case FacilityFilterType.all:
        return _results;
      case FacilityFilterType.elevator:
        return _results.where((f) => f.kind == FacilityKind.elevator).toList();
      case FacilityFilterType.escalator:
        return _results.where((f) => f.kind == FacilityKind.escalator).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final filtered = _filteredResults;

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
                Text('편의시설 현황', style: t.headlineLarge),
                const SizedBox(height: AppSpacing.space12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                        style: t.bodyLarge,
                        decoration: const InputDecoration(hintText: '예: 강남'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    FilledButton(
                      onPressed: _loading ? null : _search,
                      child: Text(_loading ? '조회 중' : '조회'),
                    ),
                  ],
                ),
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space12),
                  FacilityTypeFilter(
                    selected: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                ],
              ],
            ),
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),
        Expanded(
          child: _error != null
              ? ListView(
                  padding: AppSpacing.screenInsets,
                  children: [
                    _MessageBox(
                      icon: Icons.error_outline,
                      color: cs.onErrorContainer,
                      bg: cs.errorContainer,
                      text: _error!,
                    ),
                  ],
                )
              : (!_loading && _results.isEmpty)
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPadding,
                              vertical: AppSpacing.space32),
                          child: Column(
                            children: [
                              Icon(Icons.elevator_outlined,
                                  size: 40, color: cs.onSurfaceVariant),
                              const SizedBox(height: AppSpacing.space12),
                              Text(
                                '역명을 입력하고 조회를 눌러 실제 엘리베이터·\n에스컬레이터 위치를 확인하세요.',
                                textAlign: TextAlign.center,
                                style: t.bodyMedium
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                          top: AppSpacing.space12, bottom: AppSpacing.space24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _FacilityTile(facility: filtered[i]),
                    ),
        ),
      ],
    );
  }
}

class _FacilityTile extends StatelessWidget {
  final Facility facility;
  const _FacilityTile({required this.facility});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final isElevator = facility.kind == FacilityKind.elevator;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.space12,
      ),
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            ),
            child: Icon(
              isElevator ? Icons.elevator : Icons.escalator,
              color: cs.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${facility.stationName} · ${isElevator ? '엘리베이터' : '에스컬레이터'}',
                  style: t.titleMedium,
                ),
                const SizedBox(height: AppSpacing.space4),
                Wrap(
                  spacing: AppSpacing.space8,
                  runSpacing: AppSpacing.space4,
                  children: [
                    if (facility.exit.isNotEmpty) _MiniBadge('출구 ${facility.exit}'),
                    if (isElevator && facility.capacityKg.isNotEmpty)
                      _MiniBadge('${facility.capacityKg}kg'),
                  ],
                ),
                if (facility.detail.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space4),
                  Text(facility.detail,
                      style:
                          t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  const _MiniBadge(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.space8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Text(text,
          style: t.labelSmall?.copyWith(
              color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String text;
  const _MessageBox({
    required this.icon,
    required this.color,
    required this.bg,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.space8),
          Expanded(child: Text(text, style: t.bodyMedium?.copyWith(color: color))),
        ],
      ),
    );
  }
}
