import 'package:flutter/material.dart';

enum FacilityFilterType { all, elevator, escalator }

/// 역 접근성 화면의 시설 종류 필터 — 조회 결과가 많을 때 엘리베이터/
/// 에스컬레이터만 골라 보게 해 스크롤을 줄인다.
class FacilityTypeFilter extends StatelessWidget {
  final FacilityFilterType selected;
  final ValueChanged<FacilityFilterType> onChanged;

  const FacilityTypeFilter(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<FacilityFilterType>(
      segments: const [
        ButtonSegment(value: FacilityFilterType.all, label: Text('전체')),
        ButtonSegment(
          value: FacilityFilterType.elevator,
          label: Text('엘리베이터'),
          icon: Icon(Icons.elevator_outlined, size: 16),
        ),
        ButtonSegment(
          value: FacilityFilterType.escalator,
          label: Text('에스컬레이터'),
          icon: Icon(Icons.escalator_outlined, size: 16),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}
