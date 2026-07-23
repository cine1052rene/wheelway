import 'package:flutter/material.dart';
import '../data/stations.dart';
import '../models/journey.dart';
import '../models/route.dart';
import '../models/station.dart';
import '../services/journey_service.dart';
import '../services/route_engine.dart';
import '../services/wheelway_api.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/journey_timeline.dart';
import '../widgets/route/route_summary_card.dart';
import '../widgets/station_picker.dart';

/// 지름길 찾기 — 핵심 화면. 입력(프로필·출발·도착·CTA)은 화면 상단에
/// 고정하고, 결과(요약+타임라인)만 독립적으로 스크롤되게 분리했다.
/// 이전엔 결과를 본 뒤 입력을 바꾸려면 맨 위까지 다시 스크롤해야 했다.
class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final _engine = RouteEngine(stations: kStations);
  final _api = WheelwayApi();
  late final _journeyService = JourneyService(_api);

  MobilityProfile _profile = MobilityProfile.crutch;
  Station? _origin;
  Station? _destination;

  bool _loading = false;
  String? _error;
  RouteResult? _result;
  Journey? _journey;

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isOrigin) async {
    final s = await showStationPicker(context,
        title: isOrigin ? '출발역 선택' : '도착역 선택');
    if (s == null) return;
    setState(() {
      if (isOrigin) {
        _origin = s;
      } else {
        _destination = s;
      }
      _result = null;
      _journey = null;
      _error = null;
    });
  }

  void _swap() {
    setState(() {
      final tmp = _origin;
      _origin = _destination;
      _destination = tmp;
      _result = null;
      _journey = null;
      _error = null;
    });
  }

  Future<void> _findRoute() async {
    final origin = _origin;
    final dest = _destination;
    if (origin == null || dest == null) {
      setState(() => _error = '출발역과 도착역을 선택하세요.');
      return;
    }
    if (origin.id == dest.id) {
      setState(() => _error = '출발역과 도착역이 같습니다.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _journey = null;
    });
    try {
      final result = _engine.getRoute(
          fromId: origin.id, toId: dest.id, profile: _profile);
      final legs = _engine.buildLegs(result);
      final journey = await _journeyService.buildJourney(
          originName: origin.name, legs: legs);
      setState(() {
        _result = result;
        _journey = journey;
      });
    } on RouteException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '경로를 계산하는 중 문제가 발생했습니다. ($e)');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _InputHeader(
          profile: _profile,
          origin: _origin,
          destination: _destination,
          loading: _loading,
          onProfileChanged: (p) => setState(() {
            _profile = p;
            _result = null;
            _journey = null;
          }),
          onPickOrigin: () => _pick(true),
          onPickDestination: () => _pick(false),
          onSwap: _swap,
          onFindRoute: _findRoute,
        ),
        Divider(height: 1, color: cs.outlineVariant),
        Expanded(
          child: _ResultArea(
            error: _error,
            result: _result,
            journey: _journey,
          ),
        ),
      ],
    );
  }
}

/// 화면 상단 고정 입력 영역(프로필·출발/도착·CTA). 스크롤되지 않는다.
class _InputHeader extends StatelessWidget {
  final MobilityProfile profile;
  final Station? origin;
  final Station? destination;
  final bool loading;
  final ValueChanged<MobilityProfile> onProfileChanged;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;
  final VoidCallback onSwap;
  final VoidCallback onFindRoute;

  const _InputHeader({
    required this.profile,
    required this.origin,
    required this.destination,
    required this.loading,
    required this.onProfileChanged,
    required this.onPickOrigin,
    required this.onPickDestination,
    required this.onSwap,
    required this.onFindRoute,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
            AppSpacing.space12, AppSpacing.screenPadding, AppSpacing.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('지름길 찾기', style: t.headlineLarge),
            const SizedBox(height: AppSpacing.space12),
            _ProfileSelector(value: profile, onChanged: onProfileChanged),
            const SizedBox(height: AppSpacing.space12),
            _StationField(label: '출발역', station: origin, onTap: onPickOrigin),
            const SizedBox(height: AppSpacing.space4),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onSwap,
                icon: const Icon(Icons.swap_vert),
                tooltip: '출발·도착 바꾸기',
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            _StationField(
                label: '도착역', station: destination, onTap: onPickDestination),
            const SizedBox(height: AppSpacing.space12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : onFindRoute,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.route),
                label: Text(loading ? '지름길 찾는 중…' : '지름길 찾기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 결과 표시 영역(독립 스크롤) — 빈 상태 / 에러 / 결과 타임라인.
class _ResultArea extends StatelessWidget {
  final String? error;
  final RouteResult? result;
  final Journey? journey;
  const _ResultArea({required this.error, required this.result, required this.journey});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (error != null) {
      return ListView(
        padding: AppSpacing.screenInsets,
        children: [_ErrorCard(error!)],
      );
    }
    if (result == null || journey == null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding, vertical: AppSpacing.space32),
            child: Column(
              children: [
                Icon(Icons.route_outlined, size: 40, color: cs.onSurfaceVariant),
                const SizedBox(height: AppSpacing.space12),
                Text(
                  '출발·도착역을 선택하고 지름길 찾기를 눌러주세요.',
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
          AppSpacing.space16, AppSpacing.screenPadding, AppSpacing.space32),
      children: [
        RouteSummaryCard(
          profileLabel: result!.profileLabel,
          totalMinutes: result!.totalMinutes,
          transferCount: result!.transferStations.length,
        ),
        const SizedBox(height: AppSpacing.space20),
        JourneyTimeline(journey: journey!),
        const SizedBox(height: AppSpacing.space16),
        Text(
          '※ 소요시간은 평균 역간 운행시간 기준 추정치이며, 문 폭 등 미실측 값은 '
          '경로 판정에 사용하지 않습니다.',
          style: t.bodySmall?.copyWith(color: AppColors.seedSecondary),
        ),
      ],
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  final MobilityProfile value;
  final ValueChanged<MobilityProfile> onChanged;
  const _ProfileSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MobilityProfile>(
      segments: const [
        ButtonSegment(
            value: MobilityProfile.crutch,
            label: Text('목발'),
            icon: Icon(Icons.accessible)),
        ButtonSegment(
            value: MobilityProfile.manual,
            label: Text('수동'),
            icon: Icon(Icons.accessible_forward)),
        ButtonSegment(
            value: MobilityProfile.electric,
            label: Text('전동'),
            icon: Icon(Icons.electric_bolt)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}

class _StationField extends StatelessWidget {
  final String label;
  final Station? station;
  final VoidCallback onTap;
  const _StationField(
      {required this.label, required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.touchPreferred),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16, vertical: AppSpacing.space12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Text('$label  ',
                style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            Expanded(
              child: Text(
                station?.name ?? '역을 선택하세요',
                style: t.titleMedium?.copyWith(
                  color: station == null ? cs.onSurfaceVariant : cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.expand_more, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard(this.message);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
              child: Text(message,
                  style: t.bodyMedium?.copyWith(color: cs.onErrorContainer))),
        ],
      ),
    );
  }
}
