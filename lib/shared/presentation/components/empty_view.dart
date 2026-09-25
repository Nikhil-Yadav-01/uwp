import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyView({
    super.key,
    this.title = 'No Data Found',
    this.message = 'There are no items to display at this time.',
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.p24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondaryLight),
            AppGap.h16,
            Text(title, style: AppTypography.headlineSmall),
            AppGap.h8,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              AppGap.h24,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
