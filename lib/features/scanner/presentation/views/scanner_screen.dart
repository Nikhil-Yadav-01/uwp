import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../../../core/hardware/scanner/models/scanned_barcode.dart';
import '../../../../core/hardware/scanner/services/multi_barcode_batch_engine.dart';
import '../controllers/hardware_hub_controller.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _manualCodeController = TextEditingController();
  final _unitWeightController = TextEditingController(text: '0.005');
  String _selectedTemplate = 'shipping_4x6';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualCodeController.dispose();
    _unitWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;
    final hwState = ref.watch(hardwareHubProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Hardware Bridge & Studio', style: AppTypography.h1),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: archetype.brandColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: archetype.brandColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            archetype.name,
                            style: AppTypography.captionBold.copyWith(color: archetype.brandColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Multi-Barcode AR Camera, Zebra/Honeywell Laser PDA, Thermal Printing & Digital Scale',
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: hwState.isLaserActive
                            ? AppColors.success.withValues(alpha: 0.15)
                            : theme.colorScheme.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: hwState.isLaserActive ? AppColors.success : theme.colorScheme.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sensors_rounded,
                            size: 16,
                            color: hwState.isLaserActive ? AppColors.success : theme.colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hwState.isLaserActive ? 'Laser PDA: Ready' : 'Laser: Standby',
                            style: AppTypography.captionBold.copyWith(
                              color: hwState.isLaserActive ? AppColors.success : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                tabs: const [
                  Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'AI Multi-Barcode AR & Laser'),
                  Tab(icon: Icon(Icons.print_rounded), text: 'Thermal Label & Receipt Lab'),
                  Tab(icon: Icon(Icons.scale_rounded), text: 'Digital Scale & Piece Counter'),
                  Tab(icon: Icon(Icons.settings_input_antenna_rounded), text: 'Zebra / PDA Config'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tab Content
            SizedBox(
              height: 640,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBarcodeScannerTab(context, hwState, isDark, theme, archetype.brandColor),
                  _buildThermalPrinterTab(context, hwState, isDark, theme),
                  _buildDigitalScaleTab(context, hwState, isDark, theme),
                  _buildPdaConfigTab(context, hwState, isDark, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: AI Multi-Barcode AR & Laser Scanner
  // ==========================================
  Widget _buildBarcodeScannerTab(
    BuildContext context,
    HardwareHubState hwState,
    bool isDark,
    ThemeData theme,
    Color brandColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Camera AR Viewfinder Simulator
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: brandColor, width: 2),
            ),
            child: Stack(
              children: [
                // Viewfinder HUD Reticle & Instructions
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white.withValues(alpha: 0.6)),
                      const SizedBox(height: 12),
                      Text('Aim Camera / Laser at Product Barcodes', style: AppTypography.body.copyWith(color: Colors.white70)),
                      Text('AI Batch Recognition captures multiple barcodes concurrently', style: AppTypography.caption.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),

                // Simulated Bounding Boxes
                Positioned(
                  top: 40,
                  left: 30,
                  child: _buildArBoundingBox('TECH-APEX16P-256-BLK (Matched)', AppColors.success),
                ),
                Positioned(
                  top: 140,
                  right: 40,
                  child: _buildArBoundingBox('HC-FNT-50MCG-AMP (Regulated Vault)', AppColors.warning),
                ),
                Positioned(
                  bottom: 80,
                  left: 60,
                  child: _buildArBoundingBox('GROC-MILK-1L (Counted)', theme.colorScheme.primary),
                ),

                // Viewfinder Reticle Box
                Center(
                  child: Container(
                    width: 260,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Controls Bar at Bottom of Viewfinder
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => ref.read(hardwareHubProvider.notifier).toggleTorch(),
                          icon: Icon(
                            hwState.isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: hwState.isTorchOn ? Colors.yellow : Colors.white70,
                          ),
                          tooltip: 'Toggle Camera Torch',
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(hardwareHubProvider.notifier).simulateBatchCameraFrame([
                              const RawDetectedBarcode(rawValue: 'TECH-APEX16P-256-BLK', symbology: BarcodeSymbology.code128),
                              const RawDetectedBarcode(rawValue: 'HC-AMX-500-BX', symbology: BarcodeSymbology.qrCode),
                              const RawDetectedBarcode(rawValue: 'HC-FNT-50MCG-AMP', symbology: BarcodeSymbology.code128),
                              const RawDetectedBarcode(rawValue: 'GROC-MILK-1L', symbology: BarcodeSymbology.ean13),
                            ]);
                          },
                          icon: const Icon(Icons.blur_on_rounded, size: 18),
                          label: const Text('Simulate 4x Batch Capture'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(hardwareHubProvider.notifier).clearScanBatch(),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                          tooltip: 'Clear Scan Log',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Right Column: Scan History & Manual Input
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laser PDA / Barcode Intake Feed', style: AppTypography.bodyBold),
                const SizedBox(height: 8),

                // Manual / USB Scanner Input Field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Keystroke / Laser Scan Input',
                          prefixIcon: Icon(Icons.keyboard_outlined),
                          hintText: 'Press Enter or Laser trigger',
                          isDense: true,
                        ),
                        onSubmitted: (code) {
                          if (code.trim().isNotEmpty) {
                            ref.read(hardwareHubProvider.notifier).triggerSimulatedLaserScan(code.trim());
                            _manualCodeController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        if (_manualCodeController.text.trim().isNotEmpty) {
                          ref.read(hardwareHubProvider.notifier).triggerSimulatedLaserScan(_manualCodeController.text.trim());
                          _manualCodeController.clear();
                        }
                      },
                      icon: const Icon(Icons.input_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Session Scans (${hwState.scannedBatch.length})', style: AppTypography.captionBold),
                    Text('Debounce Active (1.2s)', style: AppTypography.caption.copyWith(color: AppColors.success)),
                  ],
                ),
                const Divider(height: 16),

                Expanded(
                  child: hwState.scannedBatch.isEmpty
                      ? Center(
                          child: Text(
                            'No barcodes scanned yet.\nTrigger laser or camera batch.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption,
                          ),
                        )
                      : ListView.builder(
                          itemCount: hwState.scannedBatch.length,
                          itemBuilder: (context, index) {
                            final item = hwState.scannedBatch[index];
                            final isMatch = item.matchStatus == BarcodeMatchStatus.matched;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(
                                  color: isMatch ? AppColors.success.withValues(alpha: 0.5) : theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isMatch ? Icons.check_circle_rounded : Icons.qr_code_2_rounded,
                                    size: 18,
                                    color: isMatch ? AppColors.success : theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.rawCode, style: AppTypography.bodyBold),
                                        Text(
                                          '${item.symbology.name.toUpperCase()} • ${item.timestamp.toLocal().toString().substring(11, 19)}',
                                          style: AppTypography.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isMatch ? AppColors.success.withValues(alpha: 0.15) : theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.matchStatus.name.toUpperCase(),
                                      style: AppTypography.captionBold.copyWith(
                                        color: isMatch ? AppColors.success : theme.colorScheme.onSecondaryContainer,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArBoundingBox(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: Thermal Label & Receipt Lab
  // ==========================================
  Widget _buildThermalPrinterTab(
    BuildContext context,
    HardwareHubState hwState,
    bool isDark,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Template Switcher & Print Control
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thermal Label & Slip Presets', style: AppTypography.bodyBold),
                const SizedBox(height: 12),

                ...[
                  {'id': 'shipping_4x6', 'label': '4x6 Outbound Shipping Label (ZPL)', 'icon': Icons.local_shipping_outlined},
                  {'id': 'bin_tag', 'label': '3x1 Warehouse Shelf / Bin Tag (ZPL)', 'icon': Icons.qr_code_2_rounded},
                  {'id': 'narcotics_tag', 'label': 'Schedule II Narcotic Vault Tag (ZPL)', 'icon': Icons.security_rounded},
                  {'id': 'leather_tag', 'label': 'Leather Tannery Lot Certificate (ZPL)', 'icon': Icons.layers_outlined},
                  {'id': 'pos_voucher', 'label': '80mm POS Picklist Voucher (ESC/POS)', 'icon': Icons.receipt_long_rounded},
                ].map((tpl) {
                  final isSelected = _selectedTemplate == tpl['id'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      leading: Icon(tpl['icon'] as IconData, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline),
                      title: Text(tpl['label'] as String, style: AppTypography.bodyBold),
                      onTap: () {
                        setState(() => _selectedTemplate = tpl['id'] as String);
                        ref.read(hardwareHubProvider.notifier).setZplTemplate(tpl['id'] as String);
                      },
                    ),
                  );
                }),
                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(hardwareHubProvider.notifier).sendPrintJob();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transmitted raw print job to ${hwState.connectedPrinter?.name ?? 'Thermal Printer'}'),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('Send Print Job to Thermal Driver'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Raw Command & Visual Label Canvas
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Raw Output Stream Preview', style: AppTypography.bodyBold),
                    Text('Zebra ZT411 • 203 DPI', style: AppTypography.captionBold.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
                const Divider(height: 16),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        hwState.activeZplPreview,
                        style: AppTypography.monospace.copyWith(
                          color: isDark ? const Color(0xFF4EC9B0) : const Color(0xFF006699),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text('Recent Print Transmission Log', style: AppTypography.captionBold),
                const SizedBox(height: 4),
                Container(
                  height: 90,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListView.builder(
                    itemCount: hwState.printLog.length,
                    itemBuilder: (context, idx) {
                      return Text(hwState.printLog[idx], style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: Digital Scale & Piece Counter
  // ==========================================
  Widget _buildDigitalScaleTab(
    BuildContext context,
    HardwareHubState hwState,
    bool isDark,
    ThemeData theme,
  ) {
    final weight = hwState.currentWeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Digital Weight LED Display
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live Industrial Scale Indicator', style: AppTypography.h3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('BLE SCALE ONLINE', style: AppTypography.captionBold.copyWith(color: AppColors.success)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Giant LED Weight Display
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${weight.netWeight.toStringAsFixed(3)} KG',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GROSS: ${weight.grossWeight.toStringAsFixed(3)} KG   |   TARE: ${weight.tareWeight.toStringAsFixed(3)} KG',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Colors.greenAccent.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Weight Simulation Slider
                Text('Simulate Scale Weight on Platter', style: AppTypography.captionBold),
                Slider(
                  value: weight.grossWeight.clamp(0.0, 50.0),
                  min: 0.0,
                  max: 50.0,
                  divisions: 100,
                  label: '${weight.grossWeight.toStringAsFixed(2)} kg',
                  onChanged: (val) {
                    ref.read(hardwareHubProvider.notifier).updateGrossWeight(val);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickWeightButton('0.5 kg', 0.5),
                    _buildQuickWeightButton('2.45 kg', 2.45),
                    _buildQuickWeightButton('5.0 kg', 5.0),
                    _buildQuickWeightButton('12.5 kg', 12.5),
                    _buildQuickWeightButton('25.0 kg', 25.0),
                  ],
                ),
                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref.read(hardwareHubProvider.notifier).tareScale(),
                        icon: const Icon(Icons.fitness_center_rounded),
                        label: const Text('TARE SCALE'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ref.read(hardwareHubProvider.notifier).zeroScale(),
                        icon: const Icon(Icons.exposure_zero_rounded),
                        label: const Text('ZERO SCALE'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Piece Counting Engine
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hardware Piece Counter Engine', style: AppTypography.bodyBold),
                Text('Calculates unit count from bulk weight', style: AppTypography.caption),
                const Divider(height: 20),

                TextFormField(
                  controller: _unitWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Single Piece Unit Weight (KG)',
                    prefixIcon: Icon(Icons.calculate_outlined),
                    helperText: 'e.g. 0.005 kg for an M8 bolt (5 grams)',
                  ),
                  onChanged: (val) {
                    final w = double.tryParse(val) ?? 0.005;
                    ref.read(hardwareHubProvider.notifier).setUnitPieceWeight(w);
                  },
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('CALCULATED QUANTITY', style: AppTypography.captionBold.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: 8),
                      Text(
                        '${hwState.calculatedPieceCount} PCS',
                        style: AppTypography.h1.copyWith(color: theme.colorScheme.primary, fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text('Based on ${weight.netWeight.toStringAsFixed(3)} kg net', style: AppTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Leather / Produce Derivation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Leather Remnant Surface Area:', style: AppTypography.captionBold),
                      const SizedBox(height: 4),
                      Text(
                        '~${(weight.netWeight / 0.12).toStringAsFixed(1)} sq. ft. (Bovine Grade A factor)',
                        style: AppTypography.bodyBold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickWeightButton(String label, double kg) {
    return ActionChip(
      label: Text(label),
      onPressed: () => ref.read(hardwareHubProvider.notifier).updateGrossWeight(kg),
    );
  }

  // ==========================================
  // TAB 4: Zebra / Honeywell PDA Setup
  // ==========================================
  Widget _buildPdaConfigTab(
    BuildContext context,
    HardwareHubState hwState,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zebra DataWedge & Honeywell Laser PDA Integration', style: AppTypography.h3),
                  Text('Native Android Broadcast Receiver intents and scanner profiles', style: AppTypography.caption),
                ],
              ),
              Switch(
                value: hwState.isLaserActive,
                onChanged: (_) => ref.read(hardwareHubProvider.notifier).toggleLaserTrigger(),
              ),
            ],
          ),
          const Divider(height: 24),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_suggest_outlined),
                  title: const Text('DataWedge Profile Name'),
                  subtitle: Text(hwState.activeDataWedgeProfile),
                  trailing: const Chip(label: Text('ACTIVE')),
                ),
                const ListTile(
                  leading: Icon(Icons.broadcast_on_personal_rounded),
                  title: Text('Broadcast Intent Action'),
                  subtitle: Text('com.rudraksha.warehouse.SCAN_EVENT'),
                ),
                const ListTile(
                  leading: Icon(Icons.data_array_rounded),
                  title: Text('String Data Extra Key'),
                  subtitle: Text('com.symbol.datawedge.data_string'),
                ),
                const ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('Label Type Extra Key'),
                  subtitle: Text('com.symbol.datawedge.label_type'),
                ),
                const Divider(),
                Text('Active Barcode Symbologies', style: AppTypography.bodyBold),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(avatar: Icon(Icons.check, size: 14), label: Text('Code 128')),
                    Chip(avatar: Icon(Icons.check, size: 14), label: Text('QR Code')),
                    Chip(avatar: Icon(Icons.check, size: 14), label: Text('EAN-13')),
                    Chip(avatar: Icon(Icons.check, size: 14), label: Text('Data Matrix')),
                    Chip(avatar: Icon(Icons.check, size: 14), label: Text('Code 39')),
                    Chip(avatar: Icon(Icons.check, size: 14), label: Text('PDF417')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
