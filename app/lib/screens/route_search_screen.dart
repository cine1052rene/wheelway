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
  // 노선도 화면에서 역을 탭해 넘어올 때 미리 채워 넣을 출발/도착역.
  final Station? initialOrigin;
  final Station? initialDestination;

  const RouteSearchScreen({
    super.key,
    this.initialOrigin,
    this.initialDestination,
  });

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final _engine = RouteEngine(stations: kStations);
  final _api = WheelwayApi();
  late final _journeyService = JourneyService(_api);

  MobilityProfile _profile = MobilityProfile.crutch;
  late Station? _origin = widget.initialOrigin;
  late Station? _destination = widget.initialDestination;

  bool _loading = false;
  String? _error;
  RouteResult? _result;
  Journey? _journey;

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  // 역 선택하면 바로 결과가 나오게 — 예전엔 "지름길 찾기" 버튼을 따로
  // 눌러야 했는데, 버튼 한 줄만큼 세로 공간을 아끼고 탭 한 번을 줄이려고
  // 출발·도착이 둘 다 정해지는 즉시 자동 조회한다(사용자 피드백).
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
    if (_origin != null && _destination != null) _findRoute();
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
    if (_origin != null && _destination != null) _findRoute();
  }

  Future<void> _findRoute() async {
    final origin = _origin;
    final dest = _destination;
    if (origin == null || dest == null) return;
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
          onProfileChanged: (p) {
            setState(() {
              _profile = p;
              _result = null;
              _journey = null;
            });
            if (_origin != null && _destination != null) _findRoute();
          },
          onPickOrigin: () => _pick(true),
          onPickDestination: () => _pick(false),
          onSwap: _swap,
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
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

/// 화면 상단 고정 입력 영역(프로필·출발/도착). 스크롤되지 않는다.
///
/// **CTA 버튼 제거(사용자 피드백)**: "역 선택하면 자동으로 결과가 나오게"
/// — 출발/도착이 둘 다 정해지면 [RouteSearchScreen]이 알아서 조회하므로
/// 버튼 한 줄(56dp)만큼 세로 공간을 아꼈다. 조회 중엔 이 헤더 바로 아래
/// 얇은 [LinearProgressIndicator]로만 표시(별도 박스 없음).
class _InputHeader extends StatelessWidget {
  final MobilityProfile profile;
  final Station? origin;
  final Station? destination;
  final ValueChanged<MobilityProfile> onProfileChanged;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;
  final VoidCallback onSwap;

  const _InputHeader({
    required this.profile,
    required this.origin,
    required this.destination,
    required this.onProfileChanged,
    required this.onPickOrigin,
    required this.onPickDestination,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
            AppSpacing.space8, AppSpacing.screenPadding, AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 + 프로필 선택을 한 줄로 — 네이버지도 길찾기 상단의
            // "교통수단 탭 한 줄" 배치를 참고(사용자 피드백: 이전엔 프로필
            // 선택줄이 따로 있어 세로 공간을 더 썼음).
            Row(
              children: [
                Expanded(
                  child: Text('지름길 찾기',
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: AppSpacing.space8),
                _ProfileSelector(value: profile, onChanged: onProfileChanged),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            _RouteInputBox(
              origin: origin,
              destination: destination,
              onPickOrigin: onPickOrigin,
              onPickDestination: onPickDestination,
              onSwap: onSwap,
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
                  '출발·도착역을 선택하면 바로 지름길을 찾아드려요.',
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
          AppSpacing.space12, AppSpacing.screenPadding, AppSpacing.space32),
      children: [
        RouteSummaryCard(
          totalMinutes: result!.totalMinutes,
          transferCount: result!.transferStations.length,
          legs: journey!.legs,
        ),
        const SizedBox(height: AppSpacing.space12),
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

/// 목발/수동/전동 프로필 선택 — 아이콘만 있는 원형 토글 한 줄(48dp,
/// 터치 최소 기준 유지). 예전엔 라벨까지 있는 SegmentedButton이 한 줄을
/// 통째로 차지했는데, 제목과 같은 줄에 넣기 위해 아이콘 전용으로 축소했다
/// (라벨은 Tooltip·Semantics로 접근성 유지).
class _ProfileSelector extends StatelessWidget {
  final MobilityProfile value;
  final ValueChanged<MobilityProfile> onChanged;
  const _ProfileSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final p in MobilityProfile.values) ...[
          if (p != MobilityProfile.values.first)
            const SizedBox(width: AppSpacing.space4),
          _ProfileIconButton(
            profile: p,
            selected: value == p,
            onTap: () => onChanged(p),
          ),
        ],
      ],
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  final MobilityProfile profile;
  final bool selected;
  final VoidCallback onTap;
  const _ProfileIconButton(
      {required this.profile, required this.selected, required this.onTap});

  // 목발은 이동보조기구 이용자지 휠체어 이용자가 아니라서, 휠체어
  // 심볼(Icons.accessible)이 아니라 일반 보행 아이콘을 쓴다(사용자 피드백).
  IconData get _icon => switch (profile) {
        MobilityProfile.crutch => Icons.directions_walk,
        MobilityProfile.manual => Icons.accessible_forward,
        MobilityProfile.electric => Icons.electric_bolt,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: profile.label,
      child: Semantics(
        label: '${profile.label}${selected ? " 선택됨" : ""}',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: AppSpacing.touchMin,
            height: AppSpacing.touchMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? cs.primary : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon,
                size: 22, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

/// 출발/도착역을 하나의 박스 안에 위/아래로 붙여 담고, 그 경계선 위에
/// 스위칭 버튼을 겹쳐 띄운다(네이버지도 길찾기 입력창 배치 참고).
/// 예전엔 스위칭 버튼이 별도 줄(Align+IconButton)을 차지해 세로 공간을
/// 낭비했었다(사용자 피드백).
class _RouteInputBox extends StatelessWidget {
  final Station? origin;
  final Station? destination;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;
  final VoidCallback onSwap;

  const _RouteInputBox({
    required this.origin,
    required this.destination,
    required this.onPickOrigin,
    required this.onPickDestination,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(color: cs.outline),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              _RouteInputRow(
                icon: Icons.trip_origin,
                iconColor: cs.primary,
                label: '출발역',
                station: origin,
                onTap: onPickOrigin,
              ),
              Divider(
                  height: 1,
                  color: cs.outlineVariant,
                  indent: AppSpacing.space16),
              _RouteInputRow(
                icon: Icons.flag,
                iconColor: cs.error,
                label: '도착역',
                station: destination,
                onTap: onPickDestination,
              ),
            ],
          ),
          Positioned(
            right: AppSpacing.space8,
            top: AppSpacing.touchMin - 20,
            child: _SwapButton(onTap: onSwap),
          ),
        ],
      ),
    );
  }
}

class _RouteInputRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Station? station;
  final VoidCallback onTap;

  const _RouteInputRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.touchMin),
        // 오른쪽은 겹쳐 뜨는 스위칭 버튼과 부딪히지 않게 여백 확보.
        padding: const EdgeInsets.fromLTRB(AppSpacing.space16,
            AppSpacing.space8, AppSpacing.space48 + AppSpacing.space8, AppSpacing.space8),
        child: Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: AppSpacing.space12),
            Text('$label  ',
                style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            Expanded(
              child: Text(
                station?.name ?? '역을 선택하세요',
                style: t.titleMedium?.copyWith(
                  color: station == null ? cs.onSurfaceVariant : cs.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SwapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: '출발·도착 바꾸기',
      button: true,
      child: Material(
        color: cs.surface,
        shape: CircleBorder(side: BorderSide(color: cs.outline)),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.swap_vert, size: 20),
          ),
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
