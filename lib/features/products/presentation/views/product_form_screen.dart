import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
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

  // Temporary local state for variant generator
  final Map<String, TextEditingController> _variantControllers = {};
  final TextEditingController _recipeChildNameCtrl = TextEditingController();
  final TextEditingController _recipeChildSkuCtrl = TextEditingController();
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipeChildNameCtrl.dispose();
    _recipeChildSkuCtrl.dispose();
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
        title: Text(isEditing ? 'Edit Product' : 'Create ${archetype.name} Item'),
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
            Tab(icon: Icon(Icons.info_outline_rounded), text: '1. Basic Info'),
            Tab(icon: Icon(Icons.tune_rounded), text: '2. Custom Schema'),
            Tab(icon: Icon(Icons.style_outlined), text: '3. Matrix Variants'),
            Tab(icon: Icon(Icons.blender_outlined), text: '4. Recipe / BOM'),
            Tab(icon: Icon(Icons.swap_horiz_rounded), text: '5. Multi-Tier UOM'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _handleSave(formNotifier),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(isEditing ? 'Update Item' : 'Save Product'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(formState, formNotifier, archetype, isDark),
            _buildCustomSchemaTab(formState, formNotifier, archetype, isDark),
            _buildMatrixVariantsTab(formState, formNotifier, isDark),
            _buildRecipeBomTab(formState, formNotifier, isDark),
            _buildUomConversionTab(formState, formNotifier, isDark),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: BASIC INFO & PRICING ---
  Widget _buildBasicInfoTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    BusinessArchetype archetype,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Core Product Identification', style: AppTypography.headlineSmall),
              AppGap.h16,
              TextFormField(
                initialValue: formState.name,
                decoration: const InputDecoration(
                  labelText: 'Product / Item Name *',
                  hintText: 'e.g. Tuscan Full Grain Leather Roll / Pro Max Smartphone',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Product name is required' : null,
                onChanged: notifier.updateName,
              ),
              AppGap.h16,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: formState.sku,
                      decoration: const InputDecoration(
                        labelText: 'SKU *',
                        hintText: 'e.g. LTH-001',
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
                        labelText: 'Barcode (UPC / EAN / QR) *',
                        hintText: 'Scan or enter barcode',
                        suffixIcon: Icon(Icons.qr_code_scanner_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Barcode is required' : null,
                      onChanged: notifier.updateBarcode,
                    ),
                  ),
                ],
              ),
              AppGap.h16,
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: formState.category,
                      decoration: const InputDecoration(labelText: 'Category'),
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
                      decoration: const InputDecoration(labelText: 'Primary UOM (Unit of Measure)'),
                      items: archetype.supportedUoms
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) => val != null ? notifier.updateBaseUom(val) : null,
                    ),
                  ),
                ],
              ),
              AppGap.h24,
              const Divider(),
              AppGap.h16,
              Text('Pricing & Inventory Levels', style: AppTypography.headlineSmall),
              AppGap.h16,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: formState.costPrice.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (\$) *',
                        prefixText: '\$ ',
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
                        labelText: 'Selling Price (\$) *',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => double.tryParse(val ?? '') == null ? 'Enter valid selling price' : null,
                      onChanged: (val) => notifier.updateSellingPrice(double.tryParse(val) ?? 0.0),
                    ),
                  ),
                ],
              ),
              AppGap.h16,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: formState.stockQuantity.toString(),
                      decoration: InputDecoration(
                        labelText: 'Initial Stock Quantity (${formState.baseUom}) *',
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
                        labelText: 'Reorder / Min Stock Alert (${formState.baseUom}) *',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) => notifier.updateMinStock(double.tryParse(val) ?? 10.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: POLYMORPHIC DYNAMIC SCHEMA FIELDS ---
  Widget _buildCustomSchemaTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    BusinessArchetype archetype,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(archetype.icon, color: archetype.brandColor, size: 24),
                  AppGap.w8,
                  Text(
                    '${archetype.name} Custom Fields',
                    style: AppTypography.headlineSmall,
                  ),
                ],
              ),
              AppGap.h4,
              Text(
                'These dynamic attributes are rendered automatically from the ${archetype.name} schema.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppGap.h24,

              // Dynamically build input controls for each custom field definition
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
                    fieldWidget = SwitchListTile(
                      title: Text(field.label, style: AppTypography.bodyMedium),
                      subtitle: field.helperText != null ? Text(field.helperText!) : null,
                      value: (currentValue as bool?) ?? false,
                      onChanged: (val) => notifier.setCustomAttribute(field.key, val),
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
                          suffixIcon: const Icon(Icons.calendar_today_rounded),
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
                  padding: const EdgeInsets.only(bottom: 16),
                  child: fieldWidget,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 3: MULTI-VARIANT MATRIX GENERATOR ---
  Widget _buildMatrixVariantsTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Multi-Variant Matrix Generator', style: AppTypography.headlineSmall),
              AppGap.h4,
              Text(
                'Generate Cartesian SKUs (e.g. Size S, M, L × Color Black, Navy) with individual stock and barcodes.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppGap.h20,

              ElevatedButton.icon(
                onPressed: () => _showVariantGeneratorDialog(notifier),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Generate Matrix Variants'),
              ),
              AppGap.h20,

              if (formState.variants.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.3)
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                  ),
                  child: Center(
                    child: Text(
                      'No variants generated yet. Click "Generate Matrix Variants" to build size/color combinations.',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
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
                    return ListTile(
                      tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      title: Text(variant.displayName, style: AppTypography.labelLarge),
                      subtitle: Text('SKU: ${variant.sku} • Barcode: ${variant.barcode}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${variant.stockQuantity} ${formState.baseUom}'),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
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
      ),
    );
  }

  // --- TAB 4: RECIPE / BOM COMPOSER ---
  Widget _buildRecipeBomTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bill of Materials (BOM) & Recipe Composer', style: AppTypography.headlineSmall),
              AppGap.h4,
              Text(
                'Define child raw materials or ingredients that are deducted automatically upon selling or assembling this item.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppGap.h20,

              // Add Ingredient Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _recipeChildNameCtrl,
                            decoration: const InputDecoration(labelText: 'Child Component Name'),
                          ),
                        ),
                        AppGap.w12,
                        Expanded(
                          child: TextField(
                            controller: _recipeQtyCtrl,
                            decoration: InputDecoration(labelText: 'Qty Required (${formState.baseUom})'),
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
                                childSku: 'SKU-$name',
                                quantityRequired: qty,
                                uom: formState.baseUom,
                              ),
                            );
                            _recipeChildNameCtrl.clear();
                            _recipeQtyCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Component'),
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: formState.recipeBOM.length,
                separatorBuilder: (context, index) => AppGap.h8,
                itemBuilder: (context, index) {
                  final comp = formState.recipeBOM[index];
                  return ListTile(
                    tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    title: Text(comp.childProductName, style: AppTypography.labelLarge),
                    subtitle: Text('Deduction: ${comp.quantityRequired} ${comp.uom} per unit'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () => notifier.removeRecipeComponent(comp.childProductId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 5: MULTI-TIER UOM CONVERSIONS ---
  Widget _buildUomConversionTab(
    ProductFormState formState,
    ProductFormNotifier notifier,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Packaging Multi-Tier UOM Ratios', style: AppTypography.headlineSmall),
              AppGap.h4,
              Text(
                'Define custom packaging conversions (e.g. 1 Master Carton = 10 Inner Boxes = 100 Pcs).',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppGap.h20,

              // Add Conversion Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _uomFromCtrl,
                            decoration: const InputDecoration(labelText: 'From UOM (e.g. 1 Box)'),
                          ),
                        ),
                        AppGap.w12,
                        Expanded(
                          child: TextField(
                            controller: _uomMultiplierCtrl,
                            decoration: const InputDecoration(labelText: 'Multiplier (e.g. 25)'),
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
                          final to = _uomToCtrl.text.trim().isNotEmpty
                              ? _uomToCtrl.text.trim()
                              : formState.baseUom;
                          final mult = double.tryParse(_uomMultiplierCtrl.text) ?? 1.0;

                          if (from.isNotEmpty && mult > 0) {
                            notifier.addUomConversion(
                              UomConversionRatio(fromUom: from, toUom: to, multiplier: mult),
                            );
                            _uomFromCtrl.clear();
                            _uomMultiplierCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Packaging Tier'),
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: formState.uomConversions.length,
                separatorBuilder: (context, index) => AppGap.h8,
                itemBuilder: (context, index) {
                  final ratio = formState.uomConversions[index];
                  return ListTile(
                    tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    title: Text(ratio.toString(), style: AppTypography.labelLarge),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () => notifier.removeUomConversion(index),
                    ),
                  );
                },
              ),
            ],
          ),
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
