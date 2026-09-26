import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/putaway_task.dart';
import '../controllers/inbound_controller.dart';

class PutawayConfirmModal extends ConsumerStatefulWidget {
  final PutawayTask task;

  const PutawayConfirmModal({super.key, required this.task});

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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.move_to_inbox_rounded, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confirm Directed Putaway', style: AppTypography.h3),
                        Text('Task: ${widget.task.id}', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(height: 24),

            // Item Details Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.task.productName, style: AppTypography.bodyBold),
                  const SizedBox(height: 4),
                  Text('SKU: ${widget.task.sku} • Qty: ${widget.task.quantity} ${widget.task.uom}', style: AppTypography.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.task.zoneType.name.toUpperCase(),
                          style: AppTypography.captionBold.copyWith(color: theme.colorScheme.onSecondaryContainer),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Source: ${widget.task.sourceDockLocation}', style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Target Bin / Storage Location *',
                prefixIcon: Icon(Icons.location_on_outlined),
                helperText: 'Verified via physical shelf barcode scan or confirmation',
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _operatorController,
              decoration: const InputDecoration(
                labelText: 'Putaway Operator Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await ref.read(inboundNotifierProvider.notifier).confirmPutawayTask(
                      taskId: widget.task.id,
                      confirmedLocation: _locationController.text.trim(),
                      operatorName: _operatorController.text.trim(),
                    );
                    if (context.mounted && success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Putaway confirmed to ${_locationController.text.trim()}'),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Confirm Bin Putaway'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
