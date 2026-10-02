import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/return_request.dart';
import 'return_detail_modal.dart';

class ReturnCard extends StatelessWidget {
  final ReturnRequest returnRequest;
  final VoidCallback? onApprove;
  final VoidCallback? onReceive;
  final Function(String bin)? onRestock;
  final VoidCallback? onScrap;

  const ReturnCard({
    super.key,
    required this.returnRequest,
    this.onApprove,
    this.onReceive,
    this.onRestock,
    this.onScrap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          onTap: () => ReturnDetailModal.show(
            context,
            returnRequest: returnRequest,
            onApprove: onApprove,
            onReceive: onReceive,
            onRestock: onRestock,
            onScrap: onScrap,
          ),
          child: Padding(
            padding: AppPadding.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Return Number + Reason Pill + Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: returnRequest.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.r6),
                      ),
                      child: Icon(Icons.assignment_return_outlined, size: 16, color: returnRequest.status.color),
                    ),
                    AppGap.w8,
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Text(
                            returnRequest.returnNumber,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ref: ${returnRequest.salesOrderNumber}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: returnRequest.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                        border: Border.all(color: returnRequest.status.color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        returnRequest.status.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: returnRequest.status.color),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Product details, Reason, and Location
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 480;

                    final reasonPill = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                      ),
                      child: Text(
                        returnRequest.reason.label,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    );

                    final trackingPill = returnRequest.trackingNumber != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_shipping_outlined, size: 13, color: AppColors.textSecondaryLight),
                              AppGap.w4,
                              Text('Track: ${returnRequest.trackingNumber}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                            ],
                          )
                        : null;

                    final binPill = returnRequest.assignedBinLocation != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inbox_outlined, size: 13, color: AppColors.success),
                              AppGap.w4,
                              Text('Bin: ${returnRequest.assignedBinLocation}', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : null;

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            returnRequest.productName,
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppGap.h4,
                          Text(
                            'SKU: ${returnRequest.sku} • Qty: ${returnRequest.quantity} • Customer: ${returnRequest.customerName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppGap.h8,
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              reasonPill,
                              if (trackingPill != null) trackingPill,
                              if (binPill != null) binPill,
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    returnRequest.productName,
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'SKU: ${returnRequest.sku} • Qty: ${returnRequest.quantity} • Customer: ${returnRequest.customerName}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            AppGap.w8,
                            reasonPill,
                          ],
                        ),
                        if (trackingPill != null || binPill != null) ...[
                          AppGap.h8,
                          Row(
                            children: [
                              if (trackingPill != null) trackingPill,
                              if (trackingPill != null && binPill != null) AppGap.w12,
                              if (binPill != null) binPill,
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
