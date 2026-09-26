import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/hardware/scanner/models/scanned_barcode.dart';
import '../../../../core/hardware/scanner/services/zebra_datawedge_bridge.dart';
import '../../../../core/hardware/scanner/services/multi_barcode_batch_engine.dart';
import '../../../../core/hardware/printer/models/printer_device.dart';
import '../../../../core/hardware/printer/services/mock_thermal_printer_driver.dart';
import '../../../../core/hardware/printer/services/zpl_template_generator.dart';
import '../../../../core/hardware/printer/services/esc_pos_template_generator.dart';
import '../../../../core/hardware/scale/models/weight_reading.dart';
import '../../../../core/hardware/scale/services/mock_scale_driver.dart';
import '../../../../core/hardware/scale/services/piece_counter_calculator.dart';

@immutable
class HardwareHubState {
  final List<ScannedBarcode> scannedBatch;
  final bool isLaserActive;
  final bool isTorchOn;
  final List<PrinterDevice> availablePrinters;
  final PrinterDevice? connectedPrinter;
  final String activeZplPreview;
  final List<String> printLog;
  final WeightReading currentWeight;
  final double unitWeightKg;
  final int calculatedPieceCount;
  final String activeDataWedgeProfile;
  final bool isLoading;

  const HardwareHubState({
    this.scannedBatch = const [],
    this.isLaserActive = true,
    this.isTorchOn = false,
    this.availablePrinters = const [],
    this.connectedPrinter,
    this.activeZplPreview = '',
    this.printLog = const [],
    this.currentWeight = const WeightReading(
      grossWeight: 2.450,
      tareWeight: 0.0,
      netWeight: 2.450,
    ),
    this.unitWeightKg = 0.005, // 5g per fastener bolt
    this.calculatedPieceCount = 490,
    this.activeDataWedgeProfile = 'Universal_WMS_Production',
    this.isLoading = false,
  });

  HardwareHubState copyWith({
    List<ScannedBarcode>? scannedBatch,
    bool? isLaserActive,
    bool? isTorchOn,
    List<PrinterDevice>? availablePrinters,
    PrinterDevice? connectedPrinter,
    String? activeZplPreview,
    List<String>? printLog,
    WeightReading? currentWeight,
    double? unitWeightKg,
    int? calculatedPieceCount,
    String? activeDataWedgeProfile,
    bool? isLoading,
  }) {
    return HardwareHubState(
      scannedBatch: scannedBatch ?? this.scannedBatch,
      isLaserActive: isLaserActive ?? this.isLaserActive,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      availablePrinters: availablePrinters ?? this.availablePrinters,
      connectedPrinter: connectedPrinter ?? this.connectedPrinter,
      activeZplPreview: activeZplPreview ?? this.activeZplPreview,
      printLog: printLog ?? this.printLog,
      currentWeight: currentWeight ?? this.currentWeight,
      unitWeightKg: unitWeightKg ?? this.unitWeightKg,
      calculatedPieceCount: calculatedPieceCount ?? this.calculatedPieceCount,
      activeDataWedgeProfile: activeDataWedgeProfile ?? this.activeDataWedgeProfile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HardwareHubNotifier extends StateNotifier<HardwareHubState> {
  final ZebraDataWedgeBridge _scannerBridge;
  final MultiBarcodeBatchEngine _batchEngine;
  final MockThermalPrinterDriver _printerDriver;
  final ZplTemplateGenerator _zplGen;
  final EscPosTemplateGenerator _escPosGen;
  final MockWeighingScaleDriver _scaleDriver;
  final PieceCounterCalculator _pieceCounter;

  HardwareHubNotifier({
    ZebraDataWedgeBridge? scannerBridge,
    MultiBarcodeBatchEngine? batchEngine,
    MockThermalPrinterDriver? printerDriver,
    ZplTemplateGenerator? zplGen,
    EscPosTemplateGenerator? escPosGen,
    MockWeighingScaleDriver? scaleDriver,
    PieceCounterCalculator? pieceCounter,
  })  : _scannerBridge = scannerBridge ?? ZebraDataWedgeBridge(),
        _batchEngine = batchEngine ?? MultiBarcodeBatchEngine(),
        _printerDriver = printerDriver ?? MockThermalPrinterDriver(),
        _zplGen = zplGen ?? const ZplTemplateGenerator(),
        _escPosGen = escPosGen ?? const EscPosTemplateGenerator(),
        _scaleDriver = scaleDriver ?? MockWeighingScaleDriver(),
        _pieceCounter = pieceCounter ?? const PieceCounterCalculator(),
        super(const HardwareHubState()) {
    _initHardware();
  }

  Future<void> _initHardware() async {
    // 1. Listen to Laser / Scanner Stream
    _scannerBridge.barcodeStream.listen((barcode) {
      final updated = List<ScannedBarcode>.from(state.scannedBatch)..insert(0, barcode);
      state = state.copyWith(scannedBatch: updated);
    });

    // 2. Discover Printers & Generate Initial ZPL
    final printersRes = await _printerDriver.discoverPrinters();
    final defaultZpl = _zplGen.generateShippingLabel4x6(
      orderNumber: 'SO-2026-HOSP-402',
      customerName: 'St. Jude Memorial Hospital (ICU)',
      destinationAddress: 'Station 2B ICU Crash Cart',
      carrier: 'FedEx Priority Overnight',
      trackingNumber: 'TRK-2026-FEDEX-998812',
      boxNumber: 1,
      totalBoxes: 1,
      weightKg: 2.8,
      magicTrackingUrl: 'https://wms.universal.io/track/TRK-2026-FEDEX-998812',
    );

    // 3. Listen to Scale Stream
    _scaleDriver.weightStream.listen((reading) {
      final count = _pieceCounter.calculatePieceCount(
        netWeightKg: reading.netWeight,
        unitWeightKg: state.unitWeightKg,
      );
      state = state.copyWith(currentWeight: reading, calculatedPieceCount: count);
    });

    state = state.copyWith(
      availablePrinters: printersRes.fold(onSuccess: (p) => p, onFailure: (_) => []),
      connectedPrinter: _printerDriver.connectedDevice,
      activeZplPreview: defaultZpl,
      printLog: _printerDriver.printLog,
    );
  }

  // --- Scanner Actions ---
  void triggerSimulatedLaserScan(String barcode, {BarcodeSymbology symbology = BarcodeSymbology.code128}) {
    _scannerBridge.simulateScan(barcode, symbology: symbology);
  }

  void simulateBatchCameraFrame(List<RawDetectedBarcode> rawBarcodes) {
    final processed = _batchEngine.processBatch(
      detectedBarcodes: rawBarcodes,
      expectedCodes: {'TECH-APEX16P-256-BLK', 'HC-AMX-500-BX', 'HC-FNT-50MCG-AMP', 'GROC-MILK-1L'},
    );

    final updated = List<ScannedBarcode>.from(state.scannedBatch);
    for (final b in processed) {
      updated.insert(0, b);
    }
    state = state.copyWith(scannedBatch: updated);
  }

  void toggleTorch() {
    final next = !state.isTorchOn;
    _scannerBridge.setTorch(next);
    state = state.copyWith(isTorchOn: next);
  }

  void toggleLaserTrigger() {
    final next = !state.isLaserActive;
    _scannerBridge.enableLaserTrigger(next);
    state = state.copyWith(isLaserActive: next);
  }

  void clearScanBatch() {
    _batchEngine.clearHistory();
    state = state.copyWith(scannedBatch: []);
  }

  // --- Printer Actions ---
  void setZplTemplate(String templateType) {
    String zpl;
    switch (templateType) {
      case 'bin_tag':
        zpl = _zplGen.generateBinLocationLabel(
          locationString: 'Zone A • Aisle 04 • Rack 02 • Bin 11',
          zoneName: 'Main Warehouse',
          barcodeValue: 'BIN-ZA-A04-R02-B11',
        );
        break;
      case 'narcotics_tag':
        zpl = _zplGen.generateHealthcareNarcoticsTag(
          drugName: 'Fentanyl Citrate 50mcg/ml Injection',
          ndcNumber: '0409-9093-22',
          batchLot: 'LOT-FNT-9981-SEC',
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          vaultLocker: 'Vault-N01 • Safe-02 • Locker-04',
          scheduleType: 'SCHEDULE II (C-II NARCOTIC)',
        );
        break;
      case 'leather_tag':
        zpl = _zplGen.generateLeatherTextileRollTag(
          productName: 'Full-Grain Italian Cowhide (Cognac)',
          tanneryLot: 'TOSC-2026-B9',
          hideGrade: 'Grade A',
          surfaceAreaSqFt: 48.5,
          thicknessOz: '1.8mm (4.5 oz)',
          sku: 'LTHR-IT-CGN-50',
        );
        break;
      case 'pos_voucher':
        zpl = _escPosGen.generatePickVoucher(
          waveNumber: 'WAVE-104',
          pickerName: 'Alex Vance',
          zone: 'Zone A (Main)',
          items: [
            {'location': 'A01-R02-B03', 'sku': 'TECH-APEX16P', 'qty': '5'},
            {'location': 'A02-R01-B04', 'sku': 'HC-AMX-500', 'qty': '10'},
          ],
        );
        break;
      default:
        zpl = _zplGen.generateShippingLabel4x6(
          orderNumber: 'SO-2026-HOSP-402',
          customerName: 'St. Jude Memorial Hospital (ICU)',
          destinationAddress: 'Station 2B ICU Crash Cart',
          carrier: 'FedEx Priority Overnight',
          trackingNumber: 'TRK-2026-FEDEX-998812',
          boxNumber: 1,
          totalBoxes: 1,
          weightKg: 2.8,
          magicTrackingUrl: 'https://wms.universal.io/track/TRK-2026-FEDEX-998812',
        );
    }
    state = state.copyWith(activeZplPreview: zpl);
  }

  Future<void> sendPrintJob() async {
    await _printerDriver.printRaw(
      state.activeZplPreview,
      language: state.activeZplPreview.startsWith('[ESC') ? PrinterLanguage.escPos : PrinterLanguage.zpl,
    );
    state = state.copyWith(printLog: _printerDriver.printLog);
  }

  // --- Scale Actions ---
  void tareScale() {
    _scaleDriver.tare();
  }

  void zeroScale() {
    _scaleDriver.zero();
  }

  void updateGrossWeight(double targetKg) {
    _scaleDriver.simulateWeightChange(targetKg);
  }

  void setUnitPieceWeight(double weightKg) {
    state = state.copyWith(unitWeightKg: weightKg);
    final count = _pieceCounter.calculatePieceCount(
      netWeightKg: state.currentWeight.netWeight,
      unitWeightKg: weightKg,
    );
    state = state.copyWith(calculatedPieceCount: count);
  }
}

final hardwareHubProvider =
    StateNotifierProvider<HardwareHubNotifier, HardwareHubState>((ref) {
  return HardwareHubNotifier();
});
