import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/arrival.dart';
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

  // 실시간 도착정보는 별도 상태로 관리 — 이 API가 실패해도(현재 인증키가
  // 실시간 서비스 미승인 상태) 편의시설 조회 자체는 막지 않는다.
  bool _arrivalsLoading = false;
  List<StationArrival> _arrivals = const [];
  bool _arrivalsFailed = false;

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
      _arrivalsLoading = true;
      _arrivalsFailed = false;
    });
    try {
      final list = await _api.fetchStationFacilities(name);
      setState(() => _results = list);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    try {
      final arrivals = await _api.fetchArrivals(name);
      if (mounted) setState(() => _arrivals = arrivals);
    } catch (_) {
      if (mounted) setState(() => _arrivalsFailed = true);
    } finally {
      if (mounted) setState(() => _arrivalsLoading = false);
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
                      itemCount: filtered.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _ArrivalSection(
                            loading: _arrivalsLoading,
                            failed: _arrivalsFailed,
                            arrivals: _arrivals,
                          );
                        }
                        return _FacilityTile(facility: filtered[i - 1]);
                      },
                    ),
        ),
      ],
    );
  }
}

/// 실시간 도착정보 섹션. 로딩/실패/데이터 3가지 상태를 그대로 보여주고,
/// 실패해도 절대 임의의 도착시간을 지어내지 않는다(데이터 정직성 원칙 —
/// 문 폭 미실측 처리와 동일한 기준). 현재는 API 인증키가 이 서비스의
/// "실시간" 권한을 아직 승인받지 못해 항상 실패 상태로 보일 수 있음
/// (data.seoul.go.kr에서 별도 활용신청 필요 — MEMORY.md 참고).
class _ArrivalSection extends StatelessWidget {
  final bool loading;
  final bool failed;
  final List<StationArrival> arrivals;
  const _ArrivalSection({
    required this.loading,
    required this.failed,
    required this.arrivals,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    Widget body;
    if (loading) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space12),
        child: Center(
            child: SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    } else if (failed || arrivals.isEmpty) {
      body = Text(
        '실시간 도착정보를 지금은 불러올 수 없습니다.',
        style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      );
    } else {
      body = Column(
        children: [
          for (final a in arrivals.take(6)) _ArrivalTile(arrival: a),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.space16,
      ),
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.train_outlined, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.space8),
              Text('실시간 도착정보', style: t.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          body,
        ],
      ),
    );
  }
}

class _ArrivalTile extends StatelessWidget {
  final StationArrival arrival;
  const _ArrivalTile({required this.arrival});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final lineNo = arrival.lineNumber;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: lineNo != null ? AppColors.lineColor(lineNo) : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              lineNo ?? '?',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: lineNo != null ? AppColors.onLineColor(lineNo) : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              arrival.trainLineNm.isNotEmpty ? arrival.trainLineNm : arrival.direction,
              style: t.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(arrival.minutesLabel,
              style: t.bodyMedium?.copyWith(
                  color: cs.primary, fontWeight: FontWeight.w700)),
        ],
      ),
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
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        border: Border.all(color: cs.outlineVariant),
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
