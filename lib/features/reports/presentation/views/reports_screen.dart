import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../controllers/reports_controller.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportReport(String format, String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white, size: 20),
            AppGap.w12,
            Expanded(
              child: Text('Exported "$reportName" as $format format successfully.'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsNotifierProvider);
    final reportsNotifier = ref.read(reportsNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final products = ref.watch(archetypeProvider).products;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;

                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Text('Reports & BI Analytics', style: AppTypography.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              reportsState.dateRange.label,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: archetype.brandColor),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Generate detailed inventory, purchase, sales & stock audit reports with CSV/PDF exports',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final exportActions = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _exportReport('CSV / Excel', reportsState.selectedType.label),
                        icon: const Icon(Icons.table_chart_outlined, size: 16),
                        label: const Text('Export CSV'),
                      ),
                      AppGap.w8,
                      ElevatedButton.icon(
                        onPressed: () => _exportReport('PDF Document', reportsState.selectedType.label),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        label: const Text('Export PDF'),
                      ),
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        Wrap(spacing: 8, runSpacing: 8, children: [exportActions]),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      exportActions,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. Report Type Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ReportType.values.map((type) {
                    final isSelected = reportsState.selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type.label),
                        selected: isSelected,
                        selectedColor: archetype.brandColor.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? archetype.brandColor : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => reportsNotifier.setReportType(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              AppGap.h12,

              // 3. Date Range Filter & Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;

                    final searchField = TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Filter report items by SKU, name, or reference...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: reportsNotifier.setSearchQuery,
                    );

                    final dateFilter = SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: DateRangeFilter.values.map((range) {
                          final isSelected = reportsState.dateRange == range;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(range.label, style: const TextStyle(fontSize: 11)),
                              selected: isSelected,
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) => reportsNotifier.setDateRange(range),
                            ),
                          );
                        }).toList(),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          searchField,
                          const Divider(height: 16),
                          dateFilter,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 5, child: searchField),
                        AppGap.w12,
                        Expanded(flex: 5, child: dateFilter),
                      ],
                    );
                  },
                ),
              ),
              AppGap.h20,

              // 4. Report Data Table Card
              _buildReportTable(reportsState.selectedType, products, archetype.brandColor, colorScheme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTable(
    ReportType type,
    List<Map<String, dynamic>> products,
    Color brandColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    switch (type) {
      case ReportType.inventoryStock:
        return _buildInventoryStockReport(products, colorScheme, isDark);
      case ReportType.purchaseInbound:
        return _buildPurchaseInboundReport(colorScheme, isDark);
      case ReportType.salesOutbound:
        return _buildSalesOutboundReport(colorScheme, isDark);
      case ReportType.stockAgingAudit:
        return _buildStockAgingReport(products, colorScheme, isDark);
    }
  }

  Widget _buildInventoryStockReport(List<Map<String, dynamic>> products, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inventory Stock & Valuation Report (01-Sep-2026 - 30-Sep-2026)', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          AppGap.h16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return _buildMobileInventoryStockList(products, colorScheme, isDark);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('SKU Code')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Opening')),
                    DataColumn(label: Text('Inward (+)', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Outward (-)', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Closing Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Unit Cost')),
                    DataColumn(label: Text('Total Valuation', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  ],
                  rows: products.map((item) {
                    final stock = (item['stock'] as num? ?? 0).toDouble();
                    final price = (item['unitPrice'] as num? ?? 0).toDouble();
                    final inward = 40.0;
                    final outward = 15.0;
                    final opening = (stock - inward + outward).clamp(0.0, 9999.0);
                    final totalVal = stock * price;

                    return DataRow(
                      cells: [
                        DataCell(Text(item['sku'] ?? 'SKU-001', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(item['name'] ?? 'Product')),
                        DataCell(Text('${opening.toInt()}')),
                        DataCell(Text('+${inward.toInt()}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                        DataCell(Text('-${outward.toInt()}', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold))),
                        DataCell(Text('${stock.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(AppFormatters.currency(price))),
                        DataCell(Text(AppFormatters.currency(totalVal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInventoryStockList(List<Map<String, dynamic>> products, ColorScheme colorScheme, bool isDark) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No stock items found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => AppGap.h12,
      itemBuilder: (context, index) {
        final item = products[index];
        final stock = (item['stock'] as num? ?? 0).toDouble();
        final price = (item['unitPrice'] as num? ?? 0).toDouble();
        final inward = 40.0;
        final outward = 15.0;
        final opening = (stock - inward + outward).clamp(0.0, 9999.0);
        final totalVal = stock * price;

        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['sku'] ?? 'SKU-001',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              AppGap.h8,
              const Divider(height: 1),
              AppGap.h8,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  Text('Opening: ${opening.toInt()}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  Text('Inward: +${inward.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                  Text('Outward: -${outward.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
                  Text('Closing: ${stock.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              AppGap.h8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Unit Cost: ${AppFormatters.currency(price)}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  Text('Valuation: ${AppFormatters.currency(totalVal)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchaseInboundReport(ColorScheme colorScheme, bool isDark) {
    final samplePos = [
      {'po': 'PO-2026-0012', 'vendor': 'ABC Traders', 'ordered': 150, 'received': 148, 'damaged': 2, 'cost': '${AppFormatters.currencySymbol}14,800', 'status': 'Received'},
      {'po': 'PO-2026-0011', 'vendor': 'Global Suppliers', 'ordered': 80, 'received': 80, 'damaged': 0, 'cost': '${AppFormatters.currencySymbol}6,400', 'status': 'Received'},
      {'po': 'PO-2026-0010', 'vendor': 'Tech Corporation', 'ordered': 50, 'received': 30, 'damaged': 1, 'cost': '${AppFormatters.currencySymbol}28,500', 'status': 'Partial Intake'},
      {'po': 'PO-2026-0009', 'vendor': 'Toscana Leather', 'ordered': 120, 'received': 120, 'damaged': 0, 'cost': '${AppFormatters.currencySymbol}18,000', 'status': 'Received'},
    ];

    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inbound Purchase & GRN Fulfillment Report', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          AppGap.h16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return _buildMobilePurchaseInboundList(samplePos, colorScheme, isDark);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('PO Number')),
                    DataColumn(label: Text('Supplier / Vendor')),
                    DataColumn(label: Text('Ordered Qty')),
                    DataColumn(label: Text('Received Qty', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Damaged Qty', style: TextStyle(color: AppColors.error))),
                    DataColumn(label: Text('Total Invoice Cost')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: samplePos.map((po) {
                    return DataRow(
                      cells: [
                        DataCell(Text(po['po'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(po['vendor'] as String)),
                        DataCell(Text('${po['ordered']} units')),
                        DataCell(Text('${po['received']} units', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                        DataCell(Text('${po['damaged']}', style: TextStyle(color: (po['damaged'] as int) > 0 ? AppColors.error : AppColors.textSecondaryLight))),
                        DataCell(Text(po['cost'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(po['status'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePurchaseInboundList(List<Map<String, dynamic>> samplePos, ColorScheme colorScheme, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: samplePos.length,
      separatorBuilder: (_, __) => AppGap.h12,
      itemBuilder: (context, index) {
        final po = samplePos[index];
        final damaged = po['damaged'] as int;

        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(po['po'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(po['status'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ),
                ],
              ),
              AppGap.h4,
              Text(
                'Supplier: ${po['vendor']}',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              AppGap.h8,
              const Divider(height: 1),
              AppGap.h8,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  Text('Ordered: ${po['ordered']}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  Text('Received: ${po['received']}', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                  if (damaged > 0)
                    Text('Damaged: $damaged', style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                ],
              ),
              AppGap.h8,
              Align(
                alignment: Alignment.centerRight,
                child: Text('Invoice: ${po['cost']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesOutboundReport(ColorScheme colorScheme, bool isDark) {
    final sampleSos = [
      {'so': 'SO-0456', 'customer': 'XYZ Retailers', 'destination': 'Lower Parel, Mumbai', 'qty': 5, 'courier': 'DTDC Express', 'status': 'Dispatched'},
      {'so': 'SO-0457', 'customer': 'Amazon FC BLR', 'destination': 'Devanahalli, Bangalore', 'qty': 24, 'courier': 'Blue Dart', 'status': 'Shipped'},
      {'so': 'SO-0458', 'customer': 'Flipkart Logistics', 'destination': 'Hosur Road, Bangalore', 'qty': 12, 'courier': 'Delhivery', 'status': 'In Transit'},
      {'so': 'SO-0459', 'customer': 'Apollo Hospital', 'destination': 'Greams Rd, Chennai', 'qty': 8, 'courier': 'FedEx Priority', 'status': 'Delivered'},
    ];

    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outbound Sales & Shipment Dispatch Report', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          AppGap.h16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return _buildMobileSalesOutboundList(sampleSos, colorScheme, isDark);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Sales Order')),
                    DataColumn(label: Text('Customer Account')),
                    DataColumn(label: Text('Destination City')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Courier Partner')),
                    DataColumn(label: Text('Delivery Status')),
                  ],
                  rows: sampleSos.map((so) {
                    return DataRow(
                      cells: [
                        DataCell(Text(so['so'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(so['customer'] as String)),
                        DataCell(Text(so['destination'] as String)),
                        DataCell(Text('${so['qty']} units')),
                        DataCell(Text(so['courier'] as String)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(so['status'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.info)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSalesOutboundList(List<Map<String, dynamic>> sampleSos, ColorScheme colorScheme, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sampleSos.length,
      separatorBuilder: (_, __) => AppGap.h12,
      itemBuilder: (context, index) {
        final so = sampleSos[index];
        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(so['so'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(so['status'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.info)),
                  ),
                ],
              ),
              AppGap.h4,
              Text(
                'Customer: ${so['customer']}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                'Destination: ${so['destination']}',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              AppGap.h8,
              const Divider(height: 1),
              AppGap.h8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Qty: ${so['qty']} units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Courier: ${so['courier']}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockAgingReport(List<Map<String, dynamic>> products, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock Movement & Aging Analysis Report', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          AppGap.h16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return _buildMobileStockAgingList(products, colorScheme, isDark);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('SKU Code')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('0 - 30 Days (Fresh)')),
                    DataColumn(label: Text('31 - 60 Days')),
                    DataColumn(label: Text('61 - 90 Days')),
                    DataColumn(label: Text('> 90 Days (Slow)')),
                    DataColumn(label: Text('Velocity Score')),
                  ],
                  rows: products.map((item) {
                    final stock = (item['stock'] as num? ?? 0).toDouble();

                    return DataRow(
                      cells: [
                        DataCell(Text(item['sku'] ?? 'SKU-001', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(item['name'] ?? 'Product')),
                        DataCell(Text('${(stock * 0.6).toInt()}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                        DataCell(Text('${(stock * 0.25).toInt()}')),
                        DataCell(Text('${(stock * 0.1).toInt()}')),
                        DataCell(Text('${(stock * 0.05).toInt()}', style: const TextStyle(color: AppColors.error))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Fast (A)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStockAgingList(List<Map<String, dynamic>> products, ColorScheme colorScheme, bool isDark) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No aging items found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => AppGap.h12,
      itemBuilder: (context, index) {
        final item = products[index];
        final stock = (item['stock'] as num? ?? 0).toDouble();

        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Fast (A)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
              AppGap.h4,
              Text(
                'SKU: ${item['sku'] ?? 'SKU-001'}',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              AppGap.h8,
              const Divider(height: 1),
              AppGap.h8,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  Text('0-30d: ${(stock * 0.6).toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                  Text('31-60d: ${(stock * 0.25).toInt()}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  Text('61-90d: ${(stock * 0.1).toInt()}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  Text('>90d: ${(stock * 0.05).toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
