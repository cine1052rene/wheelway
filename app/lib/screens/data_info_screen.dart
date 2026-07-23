import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/page_header.dart';

class _Source {
  final String name;
  final String detail;
  const _Source(this.name, this.detail);
}

/// 데이터 정보 — 공개데이터 출처와 안전한 키 처리 방식을 투명하게 안내.
class DataInfoScreen extends StatelessWidget {
  const DataInfoScreen({super.key});

  static const List<_Source> _sources = [
    _Source('서울교통공사 편의시설 위치정보',
        '엘리베이터·에스컬레이터 위치 및 운영 상태, 5분 단위 갱신'),
    _Source('국가철도공단 역사별 엘리베이터 현황', '엘리베이터 위치·정원·운행층·제원'),
    _Source('서울교통공사 빠른하차정보',
        '하차역 기준 이동설비와 가장 가까운 열차 칸·출입문 번호'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      children: [
        const PageHeader(
          eyebrow: '신뢰할 수 있는 데이터',
          title: '데이터 정보',
          description: '공공데이터 키는 서버에만 보관하고 앱에는 노출하지 않습니다.',
        ),
        ..._sources.map(
          (s) => Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.sm,
            ),
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: t.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(s.detail, style: t.bodyMedium),
              ],
            ),
          ),
        ),
        Container(
          margin: AppSpacing.screenInsets,
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: AppColors.availableBg,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.available),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '공공 API → Firebase 서버 함수 → 앱. API 키는 Firebase Secret에만 '
                  '저장되며 앱 배포 파일에는 포함되지 않습니다.',
                  style: t.bodyMedium?.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
