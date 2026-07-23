import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 화면 상단 제목 블록 (아이브로우 + 제목 + 설명).
class PageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;

  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: t.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: t.headlineMedium),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(description!, style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}
