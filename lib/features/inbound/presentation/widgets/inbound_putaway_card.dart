import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/putaway_task.dart';
import 'putaway_confirm_modal.dart';

/// Modern, structured, and fully responsive Directed Putaway Task Card.
class InboundPutawayCard extends StatelessWidget {
  final PutawayTask task;

  const InboundPutawayCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isDone = task.isCompleted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          child: InkWell(
            onTap: isDone ? null : () => PutawayConfirmModal.show(context, task: task),
            borderRadius: BorderRadius.circular(AppRadii.r12),
            child: Container(
              padding: AppPadding.p16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.r12),
                border: Border.all(
                  color: isDone ? colorScheme.outline : colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSizes.buttonHeightSm,
                        height: AppSizes.buttonHeightSm,
                        decoration: BoxDecoration(
                          color: isDone
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check_circle_rounded : Icons.navigation_outlined,
                          color: isDone ? colorScheme.outline : colorScheme.primary,
                          size: AppSizes.iconSm + 4,
                        ),
                      ),
                      AppGap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                Text(
                                  task.productName,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppRadii.r4),
                                  ),
                                  child: Text(
                                    task.zoneType.name.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppGap.h4,
                            Text(
                              'SKU: ${task.sku} • Quantity: ${task.quantity.toStringAsFixed(0)} ${task.uom}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow && !isDone) ...[
                        AppGap.w12,
                        ElevatedButton.icon(
                          onPressed: () => PutawayConfirmModal.show(context, task: task),
                          icon: const Icon(Icons.arrow_forward_rounded, size: AppSizes.iconSm),
                          label: const Text('Confirm Bin'),
                          style: ElevatedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppGap.h12,

                  // Target Bin Pill (Flexible to prevent any overflow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colorScheme.primary),
                        AppGap.w4,
                        Flexible(
                          child: Text(
                            'Target Bin: ${task.suggestedLocation}',
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (task.confirmedLocation != null) ...[
                    AppGap.h4,
                    Text(
                      'Confirmed at: ${task.confirmedLocation}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.success),
                    ),
                  ],

                  // Mobile Action Button
                  if (isNarrow && !isDone) ...[
                    AppGap.h12,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => PutawayConfirmModal.show(context, task: task),
                        icon: const Icon(Icons.arrow_forward_rounded, size: AppSizes.iconSm),
                        label: const Text('Confirm Bin Putaway'),
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
