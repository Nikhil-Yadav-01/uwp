import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/sales_order.dart';
import '../controllers/outbound_controller.dart';

class WaveGeneratorModal extends ConsumerStatefulWidget {
  const WaveGeneratorModal({super.key});

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
    final outboundState = ref.watch(outboundNotifierProvider);
    final unassignedOrders = outboundState.salesOrders
        .where((o) => o.status == OutboundStatus.allocated || o.status == OutboundStatus.pending)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 680,
        constraints: const BoxConstraints(maxHeight: 680),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
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
                      child: Icon(Icons.bolt_rounded, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Generate Wave Picklist', style: AppTypography.h2),
                        Text('Optimized routing & FEFO sequence aggregator', style: AppTypography.caption),
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

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pickerController,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Picker / Voice Station',
                      prefixIcon: Icon(Icons.person_pin_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedZone,
                    decoration: const InputDecoration(
                      labelText: 'Fulfillment Zone',
                      prefixIcon: Icon(Icons.map_outlined),
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
            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Orders to Batch (${_selectedOrderIds.length} Selected)', style: AppTypography.bodyBold),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedOrderIds.length == unassignedOrders.length) {
                        _selectedOrderIds.clear();
                      } else {
                        _selectedOrderIds.addAll(unassignedOrders.map((o) => o.id));
                      }
                    });
                  },
                  child: Text(_selectedOrderIds.length == unassignedOrders.length ? 'Deselect All' : 'Select All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: unassignedOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No unassigned orders ready for wave dispatch.',
                        style: AppTypography.caption,
                      ),
                    )
                  : ListView.builder(
                      itemCount: unassignedOrders.length,
                      itemBuilder: (context, index) {
                        final order = unassignedOrders[index];
                        final isSelected = _selectedOrderIds.contains(order.id);
                        final isEmergency = order.priority == OrderPriority.emergencyCrashCart;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
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
                                Text(order.soNumber, style: AppTypography.bodyBold),
                                if (isEmergency) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'EMERGENCY',
                                      style: AppTypography.captionBold.copyWith(color: theme.colorScheme.onError, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              '${order.customerName} • ${order.items.length} items (${order.totalRequestedUnits.toStringAsFixed(0)} units)',
                              style: AppTypography.caption,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
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
                              SnackBar(
                                content: const Text('Optimized Wave Picklist dispatched successfully!'),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('Dispatch Wave to Floor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
