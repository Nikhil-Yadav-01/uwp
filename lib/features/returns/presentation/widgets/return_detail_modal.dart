import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/return_request.dart';

class ReturnDetailModal extends StatelessWidget {
  final ReturnRequest returnRequest;
  final VoidCallback? onApprove;
  final VoidCallback? onReceive;
  final Function(String bin)? onRestock;
  final VoidCallback? onScrap;

  const ReturnDetailModal({
    super.key,
    required this.returnRequest,
    this.onApprove,
    this.onReceive,
    this.onRestock,
    this.onScrap,
  });

  static Future<void> show(
    BuildContext context, {
    required ReturnRequest returnRequest,
    VoidCallback? onApprove,
    VoidCallback? onReceive,
    Function(String bin)? onRestock,
    VoidCallback? onScrap,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ReturnDetailModal(
        returnRequest: returnRequest,
        onApprove: onApprove,
        onReceive: onReceive,
        onRestock: onRestock,
        onScrap: onScrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r16)),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: AppPadding.p24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: returnRequest.status.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Icon(Icons.assignment_return_outlined, color: returnRequest.status.color, size: 22),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                returnRequest.returnNumber,
                                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            AppGap.w8,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: returnRequest.status.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadii.r4),
                              ),
                              child: Text(
                                returnRequest.status.label,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: returnRequest.status.color),
                              ),
                            ),
                          ],
                        ),
                        AppGap.h4,
                        Text(
                          'Order Ref: ${returnRequest.salesOrderNumber} • Customer: ${returnRequest.customerName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Item Card
              Container(
                padding: AppPadding.p12,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 24, color: AppColors.primary),
                    AppGap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(returnRequest.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('SKU: ${returnRequest.sku} • Qty: ${returnRequest.quantity} units', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h16,

              _buildDetailTile(Icons.help_outline_rounded, 'Return Reason', returnRequest.reason.label, isDark),
              if (returnRequest.trackingNumber != null)
                _buildDetailTile(Icons.local_shipping_outlined, 'Tracking Number', returnRequest.trackingNumber!, isDark),
              if (returnRequest.assignedBinLocation != null)
                _buildDetailTile(Icons.inbox_rounded, 'Restock Bin Location', returnRequest.assignedBinLocation!, isDark),
              _buildDetailTile(Icons.notes_outlined, 'Inspection Notes', returnRequest.notes.isNotEmpty ? returnRequest.notes : 'No specific notes recorded.', isDark),
              AppGap.h24,

              // Action Workflow Buttons based on Status
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                  AppGap.w8,

                  if (returnRequest.status == ReturnStatus.pending && onApprove != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onApprove?.call();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve Return'),
                    ),

                  if (returnRequest.status == ReturnStatus.approved && onReceive != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReceive?.call();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
                      icon: const Icon(Icons.move_to_inbox_rounded, size: 18),
                      label: const Text('Receive at Dock'),
                    ),

                  if (returnRequest.status == ReturnStatus.received) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onScrap?.call();
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text('Scrap / Defective'),
                    ),
                    AppGap.w8,
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRestock?.call('A01-01-01');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      icon: const Icon(Icons.inventory_rounded, size: 18),
                      label: const Text('Restock to Bin A01-01-01'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          AppGap.w10,
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
