import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/core/hardware/scanner/models/scanned_barcode.dart';
import 'package:warehouse/core/hardware/scanner/services/multi_barcode_batch_engine.dart';
import 'package:warehouse/core/hardware/scanner/services/zebra_datawedge_bridge.dart';
import 'package:warehouse/core/hardware/printer/models/printer_device.dart';
import 'package:warehouse/core/hardware/printer/services/zpl_template_generator.dart';
import 'package:warehouse/core/hardware/printer/services/esc_pos_template_generator.dart';
import 'package:warehouse/core/hardware/printer/services/mock_thermal_printer_driver.dart';
import 'package:warehouse/core/hardware/scale/services/piece_counter_calculator.dart';
import 'package:warehouse/core/hardware/scale/services/mock_scale_driver.dart';

void main() {
  group('Phase 4: Multi-Barcode Scanning Engine Tests', () {
    final batchEngine = MultiBarcodeBatchEngine(
      debounceWindow: const Duration(milliseconds: 500),
    );

    test('MultiBarcodeBatchEngine processes burst batch and matches expected SKUs', () {
      final batch = [
        const RawDetectedBarcode(
          rawValue: 'TECH-APEX16P-256-BLK',
          symbology: BarcodeSymbology.code128,
          normalizedRect: Rect.fromLTWH(0.1, 0.1, 0.3, 0.2),
        ),
        const RawDetectedBarcode(
          rawValue: 'HC-AMX-500-BX',
          symbology: BarcodeSymbology.qrCode,
          normalizedRect: Rect.fromLTWH(0.5, 0.4, 0.3, 0.2),
        ),
        const RawDetectedBarcode(
          rawValue: 'RANDOM-UNEXPECTED-BARCODE',
          symbology: BarcodeSymbology.ean13,
        ),
      ];

      final processed = batchEngine.processBatch(
        detectedBarcodes: batch,
        expectedCodes: {'TECH-APEX16P-256-BLK', 'HC-AMX-500-BX'},
      );

      expect(processed.length, equals(3));
      expect(processed[0].matchStatus, equals(BarcodeMatchStatus.matched));
      expect(processed[1].matchStatus, equals(BarcodeMatchStatus.matched));
      expect(processed[2].matchStatus, equals(BarcodeMatchStatus.unmatched));
    });

    test('ZebraDataWedgeBridge handles native intent broadcast and symbology mapping', () async {
      final bridge = ZebraDataWedgeBridge();

      expect(
        bridge.barcodeStream,
        emits(
          predicate<ScannedBarcode>((b) {
            return b.rawCode == '8901234567890' &&
                b.symbology == BarcodeSymbology.ean13;
          }),
        ),
      );

      bridge.handleNativeBroadcast(
        dataString: '8901234567890',
        labelType: 'LABEL-TYPE-EAN13',
      );

      await bridge.dispose();
    });
  });

  group('Phase 4: Thermal Printer Engine & ZPL-II Tests', () {
    const zplGen = ZplTemplateGenerator();
    const escPosGen = EscPosTemplateGenerator();

    test('ZplTemplateGenerator creates valid 4x6 Shipping Label with ZPL-II tags', () {
      final zpl = zplGen.generateShippingLabel4x6(
        orderNumber: 'SO-2026-001',
        customerName: 'Acme Corp',
        destinationAddress: '123 Warehouse Way',
        carrier: 'FedEx Express',
        trackingNumber: 'TRK-998811',
        boxNumber: 1,
        totalBoxes: 2,
        weightKg: 4.5,
        magicTrackingUrl: 'https://wms.universal.io/track/TRK-998811',
      );

      expect(zpl, startsWith('^XA'));
      expect(zpl, contains('^PW812'));
      expect(zpl, contains('^LL1218'));
      expect(zpl, contains('FEDEX EXPRESS'));
      expect(zpl, contains('Acme Corp'));
      expect(zpl, contains('TRK-998811'));
      expect(zpl, contains('^FDQA,https://wms.universal.io/track/TRK-998811^FS'));
      expect(zpl.trim(), endsWith('^XZ'));
    });

    test('ZplTemplateGenerator creates Healthcare Schedule II Narcotics Tag', () {
      final zpl = zplGen.generateHealthcareNarcoticsTag(
        drugName: 'Fentanyl Citrate 50mcg/ml',
        ndcNumber: '0409-9093-22',
        batchLot: 'LOT-FNT-9981-SEC',
        expiryDate: DateTime(2027, 5, 20),
        vaultLocker: 'Vault-01 • Safe-02',
        scheduleType: 'SCHEDULE II (C-II)',
      );

      expect(zpl, contains('SCHEDULE II (C-II)'));
      expect(zpl, contains('Fentanyl Citrate 50mcg/ml'));
      expect(zpl, contains('DUAL-WITNESS SIGN-OFF REQUIRED'));
    });

    test('EscPosTemplateGenerator generates 80mm Picklist Voucher', () {
      final receipt = escPosGen.generatePickVoucher(
        waveNumber: 'W-104',
        pickerName: 'Alex Vance',
        zone: 'Zone A',
        items: [
          {'location': 'A01-R02-B03', 'sku': 'TECH-101', 'qty': '2'},
        ],
      );

      expect(receipt, contains('[ESC @]'));
      expect(receipt, contains('UNIVERSAL WMS PICKLIST'));
      expect(receipt, contains('W-104'));
      expect(receipt, contains('[GS V 66 0]'));
    });

    test('MockThermalPrinterDriver transmits raw ZPL commands to virtual printer', () async {
      final driver = MockThermalPrinterDriver();

      final discoverRes = await driver.discoverPrinters();
      expect(discoverRes.isSuccess, isTrue);
      expect(discoverRes.dataOrNull!.length, greaterThanOrEqualTo(3));

      final printRes = await driver.printRaw('^XA^FDTEST^XZ', language: PrinterLanguage.zpl);
      expect(printRes.isSuccess, isTrue);
      expect(driver.printLog.length, equals(1));
      expect(driver.printLog.first, contains('^XA^FDTEST^XZ'));
    });
  });

  group('Phase 4: Digital Scale & Piece Counter Tests', () {
    const pieceCounter = PieceCounterCalculator();

    test('PieceCounterCalculator computes fastener quantity from net weight accurately', () {
      // 2.5 kg of bolts with 5g (0.005 kg) unit weight = 500 pieces
      final count = pieceCounter.calculatePieceCount(
        netWeightKg: 2.5,
        unitWeightKg: 0.005,
      );
      expect(count, equals(500));

      // 0.450 kg of screws with 1.5g (0.0015 kg) unit weight = 300 pieces
      final count2 = pieceCounter.calculatePieceCount(
        netWeightKg: 0.450,
        unitWeightKg: 0.0015,
      );
      expect(count2, equals(300));
    });

    test('PieceCounterCalculator derives leather remnant surface area from weight', () {
      // 6.0 kg of bovine leather with 0.12 kg/sq.ft density = 50 sq ft
      final area = pieceCounter.calculateLeatherAreaFromWeight(
        weightKg: 6.0,
        densityKgPerSqFt: 0.12,
      );
      expect(area, closeTo(50.0, 0.01));
    });

    test('PieceCounterCalculator verifies freight parcel weight tolerance', () {
      expect(
        pieceCounter.verifyFreightWeight(
          actualWeightKg: 10.2,
          expectedWeightKg: 10.0,
          tolerancePercent: 5.0, // 2% diff is within 5%
        ),
        isTrue,
      );

      expect(
        pieceCounter.verifyFreightWeight(
          actualWeightKg: 11.5,
          expectedWeightKg: 10.0,
          tolerancePercent: 5.0, // 15% diff exceeds 5%
        ),
        isFalse,
      );
    });

    test('MockWeighingScaleDriver handles live weight streaming and tare offset', () async {
      final scale = MockWeighingScaleDriver();

      expect(scale.currentNetKg, equals(2.450));

      // Tare scale
      await scale.tare();
      expect(scale.currentTareKg, equals(2.450));
      expect(scale.currentNetKg, equals(0.0));

      // Add 5kg on top of tare
      scale.simulateWeightChange(7.450);
      expect(scale.currentNetKg, closeTo(5.0, 0.001));

      // Zero scale
      await scale.zero();
      expect(scale.currentGrossKg, equals(0.0));
      expect(scale.currentTareKg, equals(0.0));
      expect(scale.currentNetKg, equals(0.0));

      scale.dispose();
    });
  });
}
