import '../models/scanned_barcode.dart';

abstract class IScannerDriver {
  Stream<ScannedBarcode> get barcodeStream;

  Future<void> initialize();

  Future<void> dispose();

  Future<void> enableLaserTrigger(bool enabled);

  Future<void> setTorch(bool enabled);

  void simulateScan(
    String rawCode, {
    BarcodeSymbology symbology = BarcodeSymbology.code128,
  });
}
