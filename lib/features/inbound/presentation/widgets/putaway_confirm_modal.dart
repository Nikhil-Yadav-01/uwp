import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../domain/models/putaway_task.dart';
import '../controllers/inbound_controller.dart';

/// Modal dialog for confirming directed bin putaway tasks.
class PutawayConfirmModal extends ConsumerStatefulWidget {
  final PutawayTask task;

  const PutawayConfirmModal({super.key, required this.task});

  static Future<void> show(BuildContext context, {required PutawayTask task}) {
    return ModalShell.show(
      context: context,
      maxWidth: 560,
      child: PutawayConfirmModal(task: task),
    );
  }

  @override
  ConsumerState<PutawayConfirmModal> createState() => _PutawayConfirmModalState();
}

class _PutawayConfirmModalState extends ConsumerState<PutawayConfirmModal> {
  late TextEditingController _locationController;
  final _operatorController = TextEditingController(text: 'Operator Marcus Staging');

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.task.suggestedLocation);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _operatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.r8),
              ),
              child: Icon(Icons.move_to_inbox_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Directed Putaway',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    'Task: ${widget.task.id}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const Divider(height: AppSpacing.lg),

        // Item Details Card
        Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.productName,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              AppGap.h4,
              Text(
                'SKU: ${widget.task.sku} • Qty: ${widget.task.quantity} ${widget.task.uom}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppGap.h8,
              Wrap(
                spacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      widget.task.zoneType.name.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Source: ${widget.task.sourceDockLocation}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppGap.h16,

        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Target Bin / Storage Location *',
            prefixIcon: Icon(Icons.location_on_outlined, size: AppSizes.iconSm),
            helperText: 'Verified via physical shelf barcode scan or confirmation',
          ),
        ),
        AppGap.h12,

        TextFormField(
          controller: _operatorController,
          decoration: const InputDecoration(
            labelText: 'Putaway Operator Name',
            prefixIcon: Icon(Icons.person_outline, size: AppSizes.iconSm),
          ),
        ),
        AppGap.h20,

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            AppGap.w12,
            ElevatedButton.icon(
              onPressed: () async {
                final loc = _locationController.text.trim();
                final op = _operatorController.text.trim();
                final success = await ref.read(inboundNotifierProvider.notifier).confirmPutawayTask(
                  taskId: widget.task.id,
                  confirmedLocation: loc,
                  operatorName: op,
                );
                if (context.mounted && success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Putaway confirmed to $loc'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_rounded, size: AppSizes.iconSm),
              label: const Text('Confirm Bin Putaway'),
            ),
          ],
        ),
      ],
    );
  }
}
