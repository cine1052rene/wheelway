import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../models/facility.dart';
import '../services/wheelway_api.dart';
import '../widgets/page_header.dart';

/// 역 접근성 — 실제 엘리베이터/에스컬레이터 위치를 라이브 API로 조회.
/// (백엔드 재사용 레이어 동작 검증을 겸한 첫 실사용 화면.)
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return ListView(
      children: [
        const PageHeader(
          eyebrow: '역별 접근성',
          title: '편의시설 현황',
          description: '역명을 입력하면 실제 엘리베이터·에스컬레이터 위치를 '
              '공개데이터에서 조회합니다.',
        ),
        Padding(
          padding: AppSpacing.screenInsets,
          child: Row(
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
        ),
        if (_error != null)
          _MessageBox(
            icon: Icons.error_outline,
            color: cs.onErrorContainer,
            bg: cs.errorContainer,
            text: _error!,
          ),
        if (!_loading && _error == null && _results.isEmpty)
          _MessageBox(
            icon: Icons.info_outline,
            color: cs.onSurfaceVariant,
            bg: cs.surfaceContainerHighest,
            text: '조회 버튼을 눌러 편의시설 위치를 불러오세요.',
          ),
        ..._results.map((f) => _FacilityTile(facility: f)),
        const SizedBox(height: AppSpacing.space24),
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
          Icon(
            isElevator ? Icons.elevator : Icons.escalator,
            color: cs.primary,
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
                Text(
                  [
                    if (facility.exit.isNotEmpty) '출구 ${facility.exit}',
                    if (facility.detail.isNotEmpty) facility.detail,
                    if (isElevator && facility.capacityKg.isNotEmpty)
                      '정격 ${facility.capacityKg}kg',
                  ].join(' · '),
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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
