import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../domain/models/sales_order.dart';
import '../controllers/outbound_controller.dart';

/// Modal dialog for batching and dispatching optimized Wave Picklists.
class WaveGeneratorModal extends ConsumerStatefulWidget {
  const WaveGeneratorModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalShell.show(
      context: context,
      maxWidth: 680,
      child: const WaveGeneratorModal(),
    );
  }

  @override
  ConsumerState<WaveGeneratorModal> createState() => _WaveGeneratorModalState();
}

class _WaveGeneratorModalState extends ConsumerState<WaveGeneratorModal> {
  final Set<String> _selectedOrderIds = {};
  final _pickerController = TextEditingController(text: 'Alex Vance (Voice PDA #2)');
  String _selectedZone = 'Zone A (Main Logistics Hub)';

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final outboundState = ref.watch(outboundNotifierProvider);
    final unassignedOrders = outboundState.salesOrders
        .where((o) => o.status == OutboundStatus.allocated || o.status == OutboundStatus.pending)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        return Column(
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
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(Icons.bolt_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Wave Picklist',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        'Optimized routing & FEFO sequence aggregator',
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

            // Picker & Zone Row/Column
            if (isNarrow) ...[
              TextFormField(
                controller: _pickerController,
                decoration: const InputDecoration(
                  labelText: 'Assigned Picker / Voice Station',
                  prefixIcon: Icon(Icons.person_pin_rounded, size: AppSizes.iconSm),
                ),
              ),
              AppGap.h12,
              DropdownButtonFormField<String>(
                initialValue: _selectedZone,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Fulfillment Zone',
                  prefixIcon: Icon(Icons.map_outlined, size: AppSizes.iconSm),
                ),
                items: const [
                  DropdownMenuItem(value: 'Zone A (Main Logistics Hub)', child: Text('Zone A (Main Hub)')),
                  DropdownMenuItem(value: 'Zone B (Cold-Chain & Perishables)', child: Text('Zone B (Cold-Chain)')),
                  DropdownMenuItem(value: 'Zone V (High-Security Narcotics Vault)', child: Text('Zone V (Narcotics Vault)')),
                ],
                onChanged: (v) => setState(() => _selectedZone = v ?? _selectedZone),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pickerController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Picker / Voice Station',
                        prefixIcon: Icon(Icons.person_pin_rounded, size: AppSizes.iconSm),
                      ),
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedZone,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Fulfillment Zone',
                        prefixIcon: Icon(Icons.map_outlined, size: AppSizes.iconSm),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Zone A (Main Logistics Hub)', child: Text('Zone A (Main Hub)')),
                        DropdownMenuItem(value: 'Zone B (Cold-Chain & Perishables)', child: Text('Zone B (Cold-Chain)')),
                        DropdownMenuItem(value: 'Zone V (High-Security Narcotics Vault)', child: Text('Zone V (Narcotics Vault)')),
                      ],
                      onChanged: (v) => setState(() => _selectedZone = v ?? _selectedZone),
                    ),
                  ),
                ],
              ),
            ],
            AppGap.h16,

            // Order Backlog Selection List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Orders to Batch (${_selectedOrderIds.length} Selected)',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: unassignedOrders.isEmpty
                      ? null
                      : () {
                          setState(() {
                            if (_selectedOrderIds.length == unassignedOrders.length) {
                              _selectedOrderIds.clear();
                            } else {
                              _selectedOrderIds.addAll(unassignedOrders.map((o) => o.id));
                            }
                          });
                        },
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: Text(
                    _selectedOrderIds.length == unassignedOrders.length ? 'Deselect All' : 'Select All',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            AppGap.h8,

            // Order Selection Items Box
            Container(
              constraints: const BoxConstraints(maxHeight: 260),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: unassignedOrders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: AppPadding.p24,
                        child: Text(
                          'No unassigned orders ready for wave dispatch.',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: unassignedOrders.length,
                      itemBuilder: (context, index) {
                        final order = unassignedOrders[index];
                        final isSelected = _selectedOrderIds.contains(order.id);
                        final isEmergency = order.priority == OrderPriority.emergencyCrashCart;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadii.r8),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedOrderIds.add(order.id);
                                } else {
                                  _selectedOrderIds.remove(order.id);
                                }
                              });
                            },
                            title: Row(
                              children: [
                                Text(
                                  order.soNumber,
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (isEmergency) ...[
                                  AppGap.w8,
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      borderRadius: BorderRadius.circular(AppRadii.r4),
                                    ),
                                    child: Text(
                                      'EMERGENCY',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colorScheme.onError,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              '${order.customerName} • ${order.items.length} items (${order.totalRequestedUnits.toStringAsFixed(0)} units)',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            AppGap.h20,

            // Footer Actions
            if (isNarrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectedOrderIds.isEmpty
                        ? null
                        : () async {
                            final success = await ref.read(outboundNotifierProvider.notifier).generateWave(
                              orderIds: _selectedOrderIds.toList(),
                              pickerName: _pickerController.text.trim(),
                              zone: _selectedZone,
                            );
                            if (context.mounted && success) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Optimized Wave Picklist dispatched successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.flash_on_rounded, size: AppSizes.iconSm),
                    label: Text('Dispatch Wave (${_selectedOrderIds.length})'),
                  ),
                  AppGap.h8,
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  AppGap.w12,
                  ElevatedButton.icon(
                    onPressed: _selectedOrderIds.isEmpty
                        ? null
                        : () async {
                            final success = await ref.read(outboundNotifierProvider.notifier).generateWave(
                              orderIds: _selectedOrderIds.toList(),
                              pickerName: _pickerController.text.trim(),
                              zone: _selectedZone,
                            );
                            if (context.mounted && success) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Optimized Wave Picklist dispatched successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.flash_on_rounded, size: AppSizes.iconSm),
                    label: Text('Dispatch Wave to Floor (${_selectedOrderIds.length})'),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
