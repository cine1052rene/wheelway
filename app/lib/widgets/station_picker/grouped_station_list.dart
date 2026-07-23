import 'package:flutter/material.dart';
import '../../models/station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

const List<String> _kInitials = [
  'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
  'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
];

/// 역명의 한글 초성(첫 자음)을 반환한다. 한글 완성형(가~힣) 범위 밖이면 '#'.
String _initialOf(String name) {
  if (name.isEmpty) return '#';
  final code = name.codeUnitAt(0);
  if (code < 0xAC00 || code > 0xD7A3) return '#';
  return _kInitials[(code - 0xAC00) ~/ 588];
}

/// 초성별로 묶어 왼쪽에 "ㄱ/ㄴ/ㄷ..." 인덱스, 오른쪽엔 그 초성으로 시작하는
/// 역명들을 여러 개씩 줄바꿈 배치한다.
///
/// 기존엔 역 하나가 한 줄 전체(ListTile)를 차지해 "강남"처럼 짧은 이름도
/// 오른쪽 대부분이 빈 공간이었다(사용자 피드백). 초성 인덱스 + Wrap
/// 그리드로 바꿔 한 화면에 훨씬 많은 역이 보이게 했다.
class GroupedStationList extends StatelessWidget {
  final List<Station> stations;
  final ValueChanged<Station> onSelected;
  final ScrollController? scrollController;

  const GroupedStationList({
    super.key,
    required this.stations,
    required this.onSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Station>>{};
    for (final s in stations) {
      (groups[_initialOf(s.name)] ??= []).add(s);
    }
    // 완성형 호환 자모 코드포인트 순서가 이미 ㄱㄲㄴㄷ… 순이라 단순 정렬로 충분.
    final keys = groups.keys.toList()..sort();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        return _GroupRow(
          label: key,
          stations: groups[key]!,
          onSelected: onSelected,
        );
      },
    );
  }
}

class _GroupRow extends StatelessWidget {
  final String label;
  final List<Station> stations;
  final ValueChanged<Station> onSelected;
  const _GroupRow(
      {required this.label, required this.stations, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                for (final s in stations)
                  _NameChip(station: s, onTap: () => onSelected(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  const _NameChip({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final lineColor = AppColors.lineColor(station.lines.first);
    // IntrinsicWidth 없이 Wrap 안에 Container(alignment 포함)를 두면
    // 무제한 폭 측정 시 칩이 한 줄 전체로 늘어나는 렌더링 버그가 재현된다
    // (line_filter_grid에서도 겪은 것과 동일한 함정 — 항상 이렇게 감쌀 것).
    return IntrinsicWidth(
      child: Semantics(
        label:
            '${station.name}역${station.hasFacility ? '' : ', 편의시설 정보 없음'}',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.only(left: 10, right: 12),
            decoration: BoxDecoration(
              color: station.hasFacility
                  ? cs.surfaceContainerHighest
                  : cs.errorContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
              border: Border(left: BorderSide(color: lineColor, width: 3)),
            ),
            alignment: Alignment.center,
            child: Text(station.name, style: t.bodyMedium),
          ),
        ),
      ),
    );
  }
}
