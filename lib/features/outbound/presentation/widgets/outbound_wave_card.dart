import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/picking_wave.dart';
import '../controllers/outbound_controller.dart';

/// Modern, structured, and responsive Picking Wave Route Card.
class OutboundWaveCard extends ConsumerWidget {
  final PickingWave wave;

  const OutboundWaveCard({
    super.key,
    required this.wave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isDone = wave.status == WaveStatus.completed;
    final totalTasks = wave.tasks.length;
    final completedTasks = wave.tasks.where((t) => t.isCompleted).length;
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Material(
      color: colorScheme.surface,
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
            // Header: Wave Number, Zone Badge & Status Chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        wave.waveNumber,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (wave.zone.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                          ),
                          child: Text(
                            wave.zone,
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AppGap.w8,
                _buildWaveStatusChip(wave.status, colorScheme),
              ],
            ),
            AppGap.h4,
            Text(
              'Picker: ${wave.assignedPickerName ?? "Unassigned"} • ${wave.orderIds.length} orders aggregated',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const Divider(height: AppSpacing.lg),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? AppColors.success : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                AppGap.w12,
                Text(
                  '$completedTasks / $totalTasks picks (${(progress * 100).toStringAsFixed(0)}%)',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDone ? AppColors.success : colorScheme.primary,
                  ),
                ),
              ],
            ),
            AppGap.h12,

            // Pick Tasks Table
            Container(
              padding: AppPadding.p12,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPTIMIZED FEFO ROUTE STOPS',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppGap.h8,
                  ...wave.tasks.map((task) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: task.isCompleted ? AppColors.success : colorScheme.outline,
                          ),
                          AppGap.w8,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${task.productName} (${task.sku})',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Location: ${task.location} • ${task.quantityToPick.toStringAsFixed(0)} units',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!task.isCompleted) ...[
                            AppGap.w8,
                            ElevatedButton(
                              onPressed: () async {
                                await ref.read(outboundNotifierProvider.notifier).confirmPickTask(
                                  waveId: wave.id,
                                  taskId: task.id,
                                  quantityPicked: task.quantityToPick,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                              ),
                              child: const Text('Pick', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveStatusChip(WaveStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case WaveStatus.created:
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        break;
      case WaveStatus.inProgress:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        break;
      case WaveStatus.completed:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        status.name.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
