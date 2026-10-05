import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/product.dart';
import '../../domain/models/recipe_component.dart';
import '../../domain/models/uom_conversion.dart';
import '../controllers/product_controller.dart';
import '../controllers/product_form_controller.dart';

/// Dynamic polymorphic product creation & edit form screen.
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Temporary local controllers
  final Map<String, TextEditingController> _variantControllers = {};
  final TextEditingController _recipeChildNameCtrl = TextEditingController();
  final TextEditingController _recipeQtyCtrl = TextEditingController();
  final TextEditingController _uomFromCtrl = TextEditingController();
  final TextEditingController _uomToCtrl = TextEditingController();
  final TextEditingController _uomMultiplierCtrl = TextEditingController();

  late StateNotifierProvider<ProductFormNotifier, ProductFormState> _formProvider;

  @override
  void initState() {
    super.initState();
    final matrixGen = ref.read(variantMatrixGeneratorProvider);
    final archetype = ref.read(archetypeProvider).archetype;

    _formProvider = StateNotifierProvider<ProductFormNotifier, ProductFormState>(
      (ref) => ProductFormNotifier(matrixGen, archetype, widget.productToEdit),
    );

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipeChildNameCtrl.dispose();
    _recipeQtyCtrl.dispose();
    _uomFromCtrl.dispose();
    _uomToCtrl.dispose();
    _uomMultiplierCtrl.dispose();
    for (final ctrl in _variantControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_formProvider);
    final formNotifier = ref.read(_formProvider.notifier);
    final archetypeState = ref.watch(archetypeProvider);
    final archetype = archetypeState.archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.r8),
              ),
              child: Icon(archetype.icon, color: colorScheme.primary, size: AppSizes.iconSm + 4),
            ),
            AppGap.w12,
            Flexible(
              child: Text(
                isEditing ? 'Edit ${formState.name.isNotEmpty ? formState.name : "Product"}' : 'Create ${archetype.name} Item',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline_rounded, size: AppSizes.iconSm), text: '1. Basic Info'),
            Tab(icon: Icon(Icons.tune_rounded, size: AppSizes.iconSm), text: '2. Custom Schema'),
            Tab(icon: Icon(Icons.style_outlined, size: AppSizes.iconSm), text: '3. Matrix Variants'),
            Tab(icon: Icon(Icons.science_outlined, size: AppSizes.iconSm), text: '4. Recipe / BOM'),
            Tab(icon: Icon(Icons.swap_horiz_rounded, size: AppSizes.iconSm), text: '5. Multi-Tier UOM'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(formState, formNotifier, archetype, isDark, colorScheme),
            _buildCustomSchemaTab(formState, formNotifier, archetype, isDark, colorScheme),
            _buildMatrixVariantsTab(formState, formNotifier, isDark, colorScheme),
            _buildRecipeBomTab(formState, formNotifier, isDark, colorScheme),
            _buildUomConversionTab(formState, formNotifier, isDark, colorScheme),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(formNotifier, isEditing, isDark, colorScheme),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: BASIC INFO, PRICING & INVENTORY
  // ---------------------------------------------------------------------------
  Widget _buildBasicInfoTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    BusinessArchetype archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Identification Section Card
                  _buildSectionCard(
                    title: 'Core Product Identification',
                    subtitle: 'SKU, barcode, and catalog categorizations',
                    icon: Icons.inventory_2_outlined,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: formState.name,
                          decoration: const InputDecoration(
                            labelText: 'Product / Item Name *',
                            hintText: 'e.g. Full Grain Leather Roll / Precision Drill Bit',
                            prefixIcon: Icon(Icons.label_outline_rounded, size: AppSizes.iconSm),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Product name is required' : null,
                          onChanged: notifier.updateName,
                        ),
                        AppGap.h16,
                        if (isNarrow) ...[
                          TextFormField(
                            initialValue: formState.sku,
                            decoration: const InputDecoration(
                              labelText: 'SKU *',
                              hintText: 'e.g. SKU-10029',
                              prefixIcon: Icon(Icons.tag_rounded, size: AppSizes.iconSm),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'SKU is required' : null,
                            onChanged: notifier.updateSku,
                          ),
                          AppGap.h16,
                          TextFormField(
                            initialValue: formState.barcode,
                            decoration: const InputDecoration(
                              labelText: 'Barcode *',
                              hintText: 'Scan or enter barcode',
                              prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: AppSizes.iconSm),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Barcode is required' : null,
                            onChanged: notifier.updateBarcode,
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: formState.sku,
                                  decoration: const InputDecoration(
                                    labelText: 'SKU *',
                                    hintText: 'e.g. SKU-10029',
                                    prefixIcon: Icon(Icons.tag_rounded, size: AppSizes.iconSm),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'SKU is required' : null,
                                  onChanged: notifier.updateSku,
                                ),
                              ),
                              AppGap.w16,
                              Expanded(
                                child: TextFormField(
                                  initialValue: formState.barcode,
                                  decoration: const InputDecoration(
                                    labelText: 'Barcode *',
                                    hintText: 'Scan or enter barcode',
                                    prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: AppSizes.iconSm),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Barcode is required' : null,
                                  onChanged: notifier.updateBarcode,
                                ),
                              ),
                            ],
                          ),
                        AppGap.h16,
                        if (isNarrow) ...[
                          DropdownButtonFormField<String>(
                            initialValue: formState.category,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category_outlined, size: AppSizes.iconSm),
                            ),
                            items: [
                              'Raw Materials',
                              'Finished Goods',
                              'Packaging',
                              'Equipment & Tools',
                              'Beverages',
                              'Controlled Stock',
                              'General',
                            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => val != null ? notifier.updateCategory(val) : null,
                          ),
                          AppGap.h16,
                          DropdownButtonFormField<String>(
                            initialValue: archetype.supportedUoms.contains(formState.baseUom)
                                ? formState.baseUom
                                : archetype.primaryUom,
                            decoration: const InputDecoration(
                              labelText: 'Primary Unit of Measure (UOM)',
                              prefixIcon: Icon(Icons.straighten_rounded, size: AppSizes.iconSm),
                            ),
                            items: archetype.supportedUoms
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) => val != null ? notifier.updateBaseUom(val) : null,
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: formState.category,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    prefixIcon: Icon(Icons.category_outlined, size: AppSizes.iconSm),
                                  ),
                                  items: [
                                    'Raw Materials',
                                    'Finished Goods',
                                    'Packaging',
                                    'Equipment & Tools',
                                    'Beverages',
                                    'Controlled Stock',
                                    'General',
                                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  onChanged: (val) => val != null ? notifier.updateCategory(val) : null,
                                ),
                              ),
                              AppGap.w16,
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: archetype.supportedUoms.contains(formState.baseUom)
                                      ? formState.baseUom
                                      : archetype.primaryUom,
                                  decoration: const InputDecoration(
                                    labelText: 'Primary Unit of Measure (UOM)',
                                    prefixIcon: Icon(Icons.straighten_rounded, size: AppSizes.iconSm),
                                  ),
                                  items: archetype.supportedUoms
                                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                      .toList(),
                                  onChanged: (val) => val != null ? notifier.updateBaseUom(val) : null,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  AppGap.h20,

                  // 2. Pricing & Margin Card
                  _buildSectionCard(
                    title: 'Pricing & Profitability',
                    subtitle: 'Cost, selling price, and real-time margin breakdown',
                    icon: Icons.currency_rupee_rounded,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    child: Column(
                      children: [
                        if (isNarrow) ...[
                          TextFormField(
                            initialValue: formState.costPrice.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Cost Price *',
                              prefixText: '${AppFormatters.currencySymbol} ',
                              prefixIcon: Icon(Icons.receipt_long_outlined, size: AppSizes.iconSm),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) => double.tryParse(val ?? '') == null ? 'Enter valid cost price' : null,
                            onChanged: (val) => notifier.updateCostPrice(double.tryParse(val) ?? 0.0),
                          ),
                          AppGap.h16,
                          TextFormField(
                            initialValue: formState.sellingPrice.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Selling Price *',
                              prefixText: '${AppFormatters.currencySymbol} ',
                              prefixIcon: Icon(Icons.sell_outlined, size: AppSizes.iconSm),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) => double.tryParse(val ?? '') == null ? 'Enter valid selling price' : null,
                            onChanged: (val) => notifier.updateSellingPrice(double.tryParse(val) ?? 0.0),
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: formState.costPrice.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Cost Price *',
                                    prefixText: '${AppFormatters.currencySymbol} ',
                                    prefixIcon: Icon(Icons.receipt_long_outlined, size: AppSizes.iconSm),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (val) => double.tryParse(val ?? '') == null ? 'Enter valid cost price' : null,
                                  onChanged: (val) => notifier.updateCostPrice(double.tryParse(val) ?? 0.0),
                                ),
                              ),
                              AppGap.w16,
                              Expanded(
                                child: TextFormField(
                                  initialValue: formState.sellingPrice.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Selling Price *',
                                    prefixText: '${AppFormatters.currencySymbol} ',
                                    prefixIcon: Icon(Icons.sell_outlined, size: AppSizes.iconSm),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (val) => double.tryParse(val ?? '') == null ? 'Enter valid selling price' : null,
                                  onChanged: (val) => notifier.updateSellingPrice(double.tryParse(val) ?? 0.0),
                                ),
                              ),
                            ],
                          ),
                        AppGap.h16,

                        // Dynamic Real-Time Margin Banner
                        _buildProfitMarginPreview(formState.costPrice, formState.sellingPrice, isDark, colorScheme),
                      ],
                    ),
                  ),
                  AppGap.h20,

                  // 3. Stock Levels & Thresholds Card
                  _buildSectionCard(
                    title: 'Inventory & Reorder Levels',
                    subtitle: 'Opening stock and automated replenishment triggers',
                    icon: Icons.layers_outlined,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    child: isNarrow
                        ? Column(
                            children: [
                              TextFormField(
                                initialValue: formState.stockQuantity.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Initial Stock Quantity (${formState.baseUom}) *',
                                  prefixIcon: const Icon(Icons.all_inbox_rounded, size: AppSizes.iconSm),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => notifier.updateStockQuantity(double.tryParse(val) ?? 0.0),
                              ),
                              AppGap.h16,
                              TextFormField(
                                initialValue: formState.minStockLevel.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Min Stock / Reorder Alert (${formState.baseUom}) *',
                                  prefixIcon: const Icon(Icons.warning_amber_rounded, size: AppSizes.iconSm),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => notifier.updateMinStock(double.tryParse(val) ?? 10.0),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: formState.stockQuantity.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Initial Stock Quantity (${formState.baseUom}) *',
                                    prefixIcon: const Icon(Icons.all_inbox_rounded, size: AppSizes.iconSm),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (val) => notifier.updateStockQuantity(double.tryParse(val) ?? 0.0),
                                ),
                              ),
                              AppGap.w16,
                              Expanded(
                                child: TextFormField(
                                  initialValue: formState.minStockLevel.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Min Stock / Reorder Alert (${formState.baseUom}) *',
                                    prefixIcon: const Icon(Icons.warning_amber_rounded, size: AppSizes.iconSm),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (val) => notifier.updateMinStock(double.tryParse(val) ?? 10.0),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: POLYMORPHIC DYNAMIC SCHEMA FIELDS
  // ---------------------------------------------------------------------------
  Widget _buildCustomSchemaTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    BusinessArchetype archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: '${archetype.name} Specific Schema',
                subtitle: 'Dynamic polymorphic attributes rendered from ${archetype.name} configuration',
                icon: archetype.icon,
                isDark: isDark,
                colorScheme: colorScheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (archetype.customFields.isEmpty)
                      Padding(
                        padding: AppPadding.p16,
                        child: Text(
                          'No dynamic schema fields defined for ${archetype.name}.',
                          style: AppTypography.bodySmall,
                        ),
                      )
                    else
                      ...archetype.customFields.map((field) {
                        final currentValue = formState.customAttributes[field.key];
                        Widget fieldWidget;

                        switch (field.dataType) {
                          case FieldDataType.dropdown:
                            fieldWidget = DropdownButtonFormField<String>(
                              initialValue: currentValue as String?,
                              decoration: InputDecoration(
                                labelText: '${field.label} ${field.isRequired ? "*" : ""}',
                                helperText: field.helperText,
                              ),
                              items: (field.options ?? [])
                                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                                  .toList(),
                              onChanged: (val) => notifier.setCustomAttribute(field.key, val),
                              validator: field.isRequired
                                  ? (val) => val == null ? '${field.label} is required' : null
                                  : null,
                            );
                            break;

                          case FieldDataType.boolean:
                            fieldWidget = Material(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadii.r8),
                                side: BorderSide(color: colorScheme.outline),
                              ),
                              child: SwitchListTile(
                                title: Text(field.label, style: AppTypography.bodyMedium),
                                subtitle: field.helperText != null ? Text(field.helperText!) : null,
                                value: (currentValue as bool?) ?? false,
                                onChanged: (val) => notifier.setCustomAttribute(field.key, val),
                              ),
                            );
                            break;

                          case FieldDataType.date:
                            fieldWidget = InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  notifier.setCustomAttribute(
                                    field.key,
                                    picked.toIso8601String().substring(0, 10),
                                  );
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: '${field.label} ${field.isRequired ? "*" : ""}',
                                  suffixIcon: const Icon(Icons.calendar_today_rounded, size: AppSizes.iconSm),
                                ),
                                child: Text(
                                  (currentValue as String?) ?? 'Tap to select date',
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            );
                            break;

                          case FieldDataType.number:
                          case FieldDataType.decimal:
                            fieldWidget = TextFormField(
                              initialValue: currentValue?.toString() ?? '',
                              decoration: InputDecoration(
                                labelText: '${field.label} ${field.isRequired ? "*" : ""}',
                                suffixText: field.unit,
                                helperText: field.helperText,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (val) => notifier.setCustomAttribute(
                                field.key,
                                double.tryParse(val) ?? val,
                              ),
                              validator: field.isRequired
                                  ? (val) => val == null || val.isEmpty ? '${field.label} is required' : null
                                  : null,
                            );
                            break;

                          case FieldDataType.text:
                          default:
                            fieldWidget = TextFormField(
                              initialValue: currentValue?.toString() ?? '',
                              decoration: InputDecoration(
                                labelText: '${field.label} ${field.isRequired ? "*" : ""}',
                                suffixText: field.unit,
                                helperText: field.helperText,
                              ),
                              onChanged: (val) => notifier.setCustomAttribute(field.key, val),
                              validator: field.isRequired
                                  ? (val) => val == null || val.trim().isEmpty ? '${field.label} is required' : null
                                  : null,
                            );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: fieldWidget,
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: MULTI-VARIANT MATRIX GENERATOR
  // ---------------------------------------------------------------------------
  Widget _buildMatrixVariantsTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Cartesian Matrix Generator',
                subtitle: 'Generate matrix SKUs (Size × Color) with individual stock tracking and barcodes',
                icon: Icons.style_outlined,
                isDark: isDark,
                colorScheme: colorScheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showVariantGeneratorDialog(notifier),
                      icon: const Icon(Icons.auto_awesome_rounded, size: AppSizes.iconSm),
                      label: const Text('Generate Matrix Variants'),
                    ),
                    AppGap.h16,
                    if (formState.variants.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: AppPadding.p32,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(AppRadii.r12),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.style_outlined, size: AppSizes.iconLg, color: colorScheme.primary.withValues(alpha: 0.5)),
                            AppGap.h8,
                            Text(
                              'No variants generated yet.',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            AppGap.h4,
                            Text(
                              'Click "Generate Matrix Variants" to automatically build Size and Color combinations.',
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: formState.variants.length,
                        separatorBuilder: (context, index) => AppGap.h8,
                        itemBuilder: (context, index) {
                          final variant = formState.variants[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppRadii.r8),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.style_outlined, size: AppSizes.iconSm, color: AppColors.info),
                                AppGap.w12,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        variant.displayName,
                                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'SKU: ${variant.sku}  •  Barcode: ${variant.barcode}',
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppRadii.r4),
                                  ),
                                  child: Text(
                                    '${variant.stockQuantity} ${formState.baseUom}',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                AppGap.w8,
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm, color: AppColors.error),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => notifier.removeVariant(variant.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: RECIPE / BOM COMPOSER
  // ---------------------------------------------------------------------------
  Widget _buildRecipeBomTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Bill of Materials (BOM) & Recipe Composer',
                    subtitle: 'Define child raw materials or ingredients deducted automatically upon assembly or sale',
                    icon: Icons.science_outlined,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Responsive Add Component Form
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(AppRadii.r8),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Child Ingredient / Component',
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              AppGap.h12,
                              if (isNarrow) ...[
                                TextField(
                                  controller: _recipeChildNameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Child Component Name',
                                    hintText: 'e.g. Leather Dye / Screws / Flour',
                                    prefixIcon: Icon(Icons.extension_outlined, size: AppSizes.iconSm),
                                  ),
                                ),
                                AppGap.h12,
                                TextField(
                                  controller: _recipeQtyCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Quantity Required (${formState.baseUom})',
                                    hintText: 'e.g. 0.5',
                                    prefixIcon: const Icon(Icons.scale_rounded, size: AppSizes.iconSm),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ] else
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _recipeChildNameCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Child Component Name',
                                          hintText: 'e.g. Leather Dye / Screws / Flour',
                                          prefixIcon: Icon(Icons.extension_outlined, size: AppSizes.iconSm),
                                        ),
                                      ),
                                    ),
                                    AppGap.w12,
                                    Expanded(
                                      child: TextField(
                                        controller: _recipeQtyCtrl,
                                        decoration: InputDecoration(
                                          labelText: 'Quantity Required (${formState.baseUom})',
                                          hintText: 'e.g. 0.5',
                                          prefixIcon: const Icon(Icons.scale_rounded, size: AppSizes.iconSm),
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      ),
                                    ),
                                  ],
                                ),
                              AppGap.h12,
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final name = _recipeChildNameCtrl.text.trim();
                                    final qty = double.tryParse(_recipeQtyCtrl.text) ?? 0.0;
                                    if (name.isNotEmpty && qty > 0) {
                                      notifier.addRecipeComponent(
                                        RecipeComponent(
                                          childProductId: 'child_${DateTime.now().millisecondsSinceEpoch}',
                                          childProductName: name,
                                          childSku: 'SKU-${name.toUpperCase().replaceAll(' ', '-')}',
                                          quantityRequired: qty,
                                          uom: formState.baseUom,
                                        ),
                                      );
                                      _recipeChildNameCtrl.clear();
                                      _recipeQtyCtrl.clear();
                                    }
                                  },
                                  icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                                  label: const Text('Add Component'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppGap.h16,

                        // Component List
                        if (formState.recipeBOM.isEmpty)
                          Padding(
                            padding: AppPadding.p16,
                            child: Text('No recipe components added yet.', style: AppTypography.bodySmall),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: formState.recipeBOM.length,
                            separatorBuilder: (context, index) => AppGap.h8,
                            itemBuilder: (context, index) {
                              final comp = formState.recipeBOM[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(AppRadii.r8),
                                  border: Border.all(color: colorScheme.outline),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.science_outlined, size: AppSizes.iconSm, color: AppColors.success),
                                    AppGap.w12,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(comp.childProductName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text('Child SKU: ${comp.childSku} • Waste: ${comp.wasteFactorPercent}%', style: AppTypography.bodySmall),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(AppRadii.r4),
                                      ),
                                      child: Text(
                                        '${comp.quantityRequired} ${comp.uom}',
                                        style: AppTypography.labelSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                    AppGap.w8,
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm, color: AppColors.error),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => notifier.removeRecipeComponent(comp.childProductId),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 5: MULTI-TIER UOM CONVERSIONS
  // ---------------------------------------------------------------------------
  Widget _buildUomConversionTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Packaging Multi-Tier UOM Ratios',
                    subtitle: 'Define packaging conversions (e.g. 1 Master Carton = 10 Inner Boxes = 100 Pcs)',
                    icon: Icons.swap_horiz_rounded,
                    isDark: isDark,
                    colorScheme: colorScheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Responsive Add Packaging Tier Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(AppRadii.r8),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Packaging Conversion Tier',
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              AppGap.h12,
                              if (isNarrow) ...[
                                TextField(
                                  controller: _uomFromCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'From Packaging UOM',
                                    hintText: 'e.g. 1 Box / 1 Carton / 1 Pallet',
                                  ),
                                ),
                                AppGap.h12,
                                TextField(
                                  controller: _uomMultiplierCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Multiplier',
                                    hintText: 'e.g. 24',
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                                AppGap.h12,
                                TextField(
                                  controller: _uomToCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'To Base UOM',
                                    hintText: formState.baseUom,
                                  ),
                                ),
                              ] else
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _uomFromCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'From Packaging UOM',
                                          hintText: 'e.g. 1 Box / 1 Carton',
                                        ),
                                      ),
                                    ),
                                    AppGap.w12,
                                    Expanded(
                                      child: TextField(
                                        controller: _uomMultiplierCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Multiplier',
                                          hintText: 'e.g. 24',
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      ),
                                    ),
                                    AppGap.w12,
                                    Expanded(
                                      child: TextField(
                                        controller: _uomToCtrl,
                                        decoration: InputDecoration(
                                          labelText: 'To Base UOM',
                                          hintText: formState.baseUom,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              AppGap.h12,
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final from = _uomFromCtrl.text.trim();
                                    final to = _uomToCtrl.text.trim().isNotEmpty ? _uomToCtrl.text.trim() : formState.baseUom;
                                    final mult = double.tryParse(_uomMultiplierCtrl.text) ?? 1.0;

                                    if (from.isNotEmpty && mult > 0) {
                                      notifier.addUomConversion(
                                        UomConversionRatio(fromUom: from, toUom: to, multiplier: mult),
                                      );
                                      _uomFromCtrl.clear();
                                      _uomMultiplierCtrl.clear();
                                    }
                                  },
                                  icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                                  label: const Text('Add Packaging Tier'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppGap.h16,

                        // Conversions List
                        if (formState.uomConversions.isEmpty)
                          Padding(
                            padding: AppPadding.p16,
                            child: Text('No packaging conversion tiers defined.', style: AppTypography.bodySmall),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: formState.uomConversions.length,
                            separatorBuilder: (context, index) => AppGap.h8,
                            itemBuilder: (context, index) {
                              final ratio = formState.uomConversions[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(AppRadii.r8),
                                  border: Border.all(color: colorScheme.outline),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined, size: AppSizes.iconSm, color: AppColors.info),
                                    AppGap.w12,
                                    Expanded(
                                      child: Text(
                                        ratio.toString(),
                                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm, color: AppColors.error),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => notifier.removeUomConversion(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER SUB-COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: AppPadding.p16,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
                child: Icon(icon, color: colorScheme.primary, size: AppSizes.iconSm + 4),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h16,
          child,
        ],
      ),
    );
  }

  Widget _buildProfitMarginPreview(
    double cost,
    double selling,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final profit = selling - cost;
    final margin = selling > 0 ? (profit / selling) * 100 : 0.0;
    final isPositive = margin >= 0;
    final color = margin >= 25 ? AppColors.success : (isPositive ? AppColors.info : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: color, size: AppSizes.iconSm + 4),
              AppGap.w8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATED MARGIN',
                    style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Unit Markup: ${AppFormatters.currency(profit)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${margin.toStringAsFixed(1)}%',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    ProductFormNotifier notifier,
    bool isEditing,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final currentIndex = _tabController.index;
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentIndex > 0) ...[
                  if (isMobile)
                    IconButton.outlined(
                      tooltip: 'Previous Tab',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _tabController.animateTo(currentIndex - 1),
                      icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _tabController.animateTo(currentIndex - 1),
                      icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm),
                      label: const Text('Previous'),
                    ),
                  AppGap.w8,
                ],
                if (currentIndex < 4) ...[
                  if (isMobile)
                    IconButton.outlined(
                      tooltip: 'Next Tab',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _tabController.animateTo(currentIndex + 1),
                      icon: const Icon(Icons.arrow_forward_rounded, size: AppSizes.iconSm),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _tabController.animateTo(currentIndex + 1),
                      icon: const Icon(Icons.arrow_forward_rounded, size: AppSizes.iconSm),
                      label: const Text('Next'),
                    ),
                  AppGap.w8,
                ],
                ElevatedButton.icon(
                  onPressed: () => _handleSave(notifier),
                  icon: const Icon(Icons.check_rounded, size: AppSizes.iconSm),
                  label: Text(
                    isMobile
                        ? (isEditing ? 'Update' : 'Save')
                        : (isEditing ? 'Update Item' : 'Save Product'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVariantGeneratorDialog(ProductFormNotifier notifier) {
    final sizesCtrl = TextEditingController(text: 'S, M, L, XL');
    final colorsCtrl = TextEditingController(text: 'Black, White, Navy');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Matrix Variants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sizesCtrl,
              decoration: const InputDecoration(
                labelText: 'Sizes (Comma-separated)',
                hintText: 'S, M, L, XL',
              ),
            ),
            AppGap.h12,
            TextField(
              controller: colorsCtrl,
              decoration: const InputDecoration(
                labelText: 'Colors (Comma-separated)',
                hintText: 'Black, White, Navy',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final sizes = sizesCtrl.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              final colors = colorsCtrl.text
                  .split(',')
                  .map((c) => c.trim())
                  .where((c) => c.isNotEmpty)
                  .toList();

              notifier.generateMatrixVariants({
                'size': sizes,
                'color': colors,
              });
              Navigator.of(context).pop();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(ProductFormNotifier notifier) async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final product = notifier.buildProduct();
    final success = await ref.read(productCatalogProvider.notifier).saveProduct(product);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product "${product.name}" saved successfully!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save product.')),
        );
      }
    }
  }
}
