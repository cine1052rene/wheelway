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
import '../widgets/page_header.dart';
import '../widgets/station_picker.dart';

/// 지름길 찾기 — 핵심 화면. 프로필·출발·도착을 고르면 라우팅 엔진으로
/// 경로를 계산하고, 실제 이동 순서 타임라인으로 확장해 보여준다.
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
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.space32),
      children: [
        const PageHeader(
          eyebrow: '교통약자 지름길',
          title: '지름길 찾기',
          description: '지상 진입부터 승차 칸, 환승, 지상 진출까지 '
              '가장 빠르고 안전한 이동 순서를 안내합니다.',
        ),
        Padding(
          padding: AppSpacing.screenInsets,
          child: Column(
            children: [
              _ProfileSelector(
                value: _profile,
                onChanged: (p) => setState(() {
                  _profile = p;
                  _result = null;
                  _journey = null;
                }),
              ),
              const SizedBox(height: AppSpacing.space16),
              _StationField(
                label: '출발역',
                station: _origin,
                onTap: () => _pick(true),
              ),
              const SizedBox(height: AppSpacing.space8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _swap,
                  icon: const Icon(Icons.swap_vert),
                  tooltip: '출발·도착 바꾸기',
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              _StationField(
                label: '도착역',
                station: _destination,
                onTap: () => _pick(false),
              ),
              const SizedBox(height: AppSpacing.space16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _findRoute,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.route),
                  label: Text(_loading ? '지름길 찾는 중…' : '지름길 찾기'),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) _ErrorCard(_error!),
        if (_result != null && _journey != null)
          _ResultSection(result: _result!, journey: _journey!),
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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

class _ResultSection extends StatelessWidget {
  final RouteResult result;
  final Journey journey;
  const _ResultSection({required this.result, required this.journey});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: AppSpacing.screenInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: cs.onPrimaryContainer),
                const SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: Text(
                    '${result.profileLabel} · 약 ${result.totalMinutes}분'
                    '${result.transferStations.isEmpty ? ' · 환승 없음' : ' · 환승 ${result.transferStations.length}회'}',
                    style: t.titleMedium
                        ?.copyWith(color: cs.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          JourneyTimeline(journey: journey),
          const SizedBox(height: AppSpacing.space16),
          Text(
            '※ 소요시간은 평균 역간 운행시간 기준 추정치이며, 문 폭 등 미실측 값은 '
            '경로 판정에 사용하지 않습니다.',
            style: t.bodySmall?.copyWith(color: AppColors.seedSecondary),
          ),
        ],
      ),
    );
  }
}
