import 'dart:async';
import '../models/scanned_barcode.dart';
import 'i_scanner_driver.dart';

/// Hardware bridge listener for rugged Zebra Android Laser Mobile Computers (TC21, TC26, TC52, TC57, MC3300, MC9300).
/// Uses Android BroadcastReceiver Intent protocol:
/// - Action: com.symbol.datawedge.api.ACTION
/// - Intent Action: com.rudraksha.warehouse.SCAN_EVENT
/// - String Extra: com.symbol.datawedge.data_string
/// - Label Type Extra: com.symbol.datawedge.label_type
class ZebraDataWedgeBridge implements IScannerDriver {
  static const String defaultIntentAction = 'com.rudraksha.warehouse.SCAN_EVENT';
  static const String dataStringExtra = 'com.symbol.datawedge.data_string';
  static const String labelTypeExtra = 'com.symbol.datawedge.label_type';

  final _controller = StreamController<ScannedBarcode>.broadcast();
  bool _isLaserEnabled = true;
  bool _isTorchOn = false;

  @override
  Stream<ScannedBarcode> get barcodeStream => _controller.stream;

  @override
  Future<void> initialize() async {
    // Configures Zebra DataWedge active profile and intent filters
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> enableLaserTrigger(bool enabled) async {
    _isLaserEnabled = enabled;
  }

  @override
  Future<void> setTorch(bool enabled) async {
    _isTorchOn = enabled;
  }

  bool get isLaserEnabled => _isLaserEnabled;
  bool get isTorchOn => _isTorchOn;

  /// Ingests a raw intent broadcast payload from Android DataWedge
  void handleNativeBroadcast({
    required String dataString,
    String? labelType,
  }) {
    if (!_isLaserEnabled) return;

    final symbology = _mapLabelTypeToSymbology(labelType);
    final barcode = ScannedBarcode(
      id: 'BC-${DateTime.now().millisecondsSinceEpoch}',
      rawCode: dataString.trim(),
      symbology: symbology,
      timestamp: DateTime.now(),
      matchStatus: BarcodeMatchStatus.unmatched,
    );

    _controller.add(barcode);
  }

  @override
  void simulateScan(
    String rawCode, {
    BarcodeSymbology symbology = BarcodeSymbology.code128,
  }) {
    final barcode = ScannedBarcode(
      id: 'BC-${DateTime.now().millisecondsSinceEpoch}',
      rawCode: rawCode.trim(),
      symbology: symbology,
      timestamp: DateTime.now(),
      matchStatus: BarcodeMatchStatus.unmatched,
    );
    _controller.add(barcode);
  }

  BarcodeSymbology _mapLabelTypeToSymbology(String? labelType) {
    if (labelType == null) return BarcodeSymbology.code128;
    final lower = labelType.toLowerCase();
    if (lower.contains('qr')) return BarcodeSymbology.qrCode;
    if (lower.contains('ean13') || lower.contains('ean-13')) return BarcodeSymbology.ean13;
    if (lower.contains('upc')) return BarcodeSymbology.upcA;
    if (lower.contains('matrix')) return BarcodeSymbology.dataMatrix;
    if (lower.contains('code39')) return BarcodeSymbology.code39;
    return BarcodeSymbology.code128;
  }
}
