import 'package:flutter/material.dart';
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.space16,
        AppSpacing.screenPadding,
        AppSpacing.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: t.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(title, style: t.headlineLarge),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              description!,
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
