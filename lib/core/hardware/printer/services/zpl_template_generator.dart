/// Template generator that produces pure, valid Zebra Programming Language (ZPL-II) code.
class ZplTemplateGenerator {
  const ZplTemplateGenerator();

  /// Generates a standard 4" x 6" Outbound Logistics Shipping Label (203 DPI: 812x1218 dots)
  String generateShippingLabel4x6({
    required String orderNumber,
    required String customerName,
    required String destinationAddress,
    required String carrier,
    required String trackingNumber,
    required int boxNumber,
    required int totalBoxes,
    required double weightKg,
    String? magicTrackingUrl,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('^XA'); // Start Format
    buffer.writeln('^PW812'); // Print Width (4 inches @ 203 DPI)
    buffer.writeln('^LL1218'); // Label Length (6 inches @ 203 DPI)
    buffer.writeln('^LH0,0'); // Label Home

    // Header Carrier Banner
    buffer.writeln('^FO30,30^GB752,90,4^FS');
    buffer.writeln('^FO50,50^A0N,45,45^FD${carrier.toUpperCase()}^FS');
    buffer.writeln('^FO560,55^A0N,30,30^FDPRIORITY EXP^FS');

    // Divider
    buffer.writeln('^FO30,130^GB752,2,2^FS');

    // Ship To Block
    buffer.writeln('^FO40,150^A0N,22,22^FDSHIP TO:^FS');
    buffer.writeln('^FO40,180^A0N,38,38^FD$customerName^FS');
    buffer.writeln('^FO40,230^A0N,28,28^FD$destinationAddress^FS');

    // Divider
    buffer.writeln('^FO30,320^GB752,2,2^FS');

    // Order & Package Metadata
    buffer.writeln('^FO40,340^A0N,28,28^FDORDER: $orderNumber^FS');
    buffer.writeln('^FO420,340^A0N,28,28^FDBOX: $boxNumber OF $totalBoxes^FS');
    buffer.writeln('^FO620,340^A0N,28,28^FDWT: ${weightKg.toStringAsFixed(1)} KG^FS');

    // Divider
    buffer.writeln('^FO30,390^GB752,2,2^FS');

    // Large Code128 Tracking Barcode
    buffer.writeln('^FO80,430^BY3,3,130'); // Barcode ratio, height 130 dots
    buffer.writeln('^BCN,130,Y,N,N^FD$trackingNumber^FS');

    // QR Code for Mobile / Magic Link
    if (magicTrackingUrl != null) {
      buffer.writeln('^FO580,620^BQN,2,6^FDQA,$magicTrackingUrl^FS');
      buffer.writeln('^FO560,780^A0N,20,20^FDMAGIC TRACKING^FS');
    }

    // Footer
    buffer.writeln('^FO40,790^A0N,22,22^FDUNIVERSAL WMS • AUTOMATED LOGISTICS MANIFEST^FS');
    buffer.writeln('^XZ'); // End Format

    return buffer.toString();
  }

  /// Generates a 3" x 1" Shelf / Bin Location Barcode Tag
  String generateBinLocationLabel({
    required String locationString,
    required String zoneName,
    required String barcodeValue,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('^XA');
    buffer.writeln('^PW609'); // 3 inches
    buffer.writeln('^LL203'); // 1 inch
    buffer.writeln('^FO20,20^GB569,163,3^FS');
    buffer.writeln('^FO40,35^A0N,30,30^FD$locationString^FS');
    buffer.writeln('^FO40,75^A0N,20,20^FDZONE: ${zoneName.toUpperCase()}^FS');
    buffer.writeln('^FO40,105^BY2,2,50^BCN,50,Y,N,N^FD$barcodeValue^FS');
    buffer.writeln('^FO440,35^BQN,2,4^FDQA,$barcodeValue^FS');
    buffer.writeln('^XZ');
    return buffer.toString();
  }

  /// Generates a Regulated Healthcare Schedule II Narcotic Vault Label
  String generateHealthcareNarcoticsTag({
    required String drugName,
    required String ndcNumber,
    required String batchLot,
    required DateTime expiryDate,
    required String vaultLocker,
    required String scheduleType,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('^XA');
    buffer.writeln('^PW609');
    buffer.writeln('^LL406');
    buffer.writeln('^FO20,20^GB569,366,4^FS');
    buffer.writeln('^FO40,40^A0N,32,32^FDREGULATED: $scheduleType^FS');
    buffer.writeln('^FO40,85^A0N,28,28^FD$drugName^FS');
    buffer.writeln('^FO40,125^A0N,22,22^FDNDC: $ndcNumber • LOT: $batchLot^FS');
    buffer.writeln('^FO40,155^A0N,22,22^FDEXP: ${expiryDate.toIso8601String().substring(0, 10)} • LOC: $vaultLocker^FS');
    buffer.writeln('^FO40,195^A0N,18,18^FDDUAL-WITNESS SIGN-OFF REQUIRED ON RETRIEVAL^FS');
    buffer.writeln('^FO40,230^BY2,2,70^BCN,70,Y,N,N^FD$ndcNumber-$batchLot^FS');
    buffer.writeln('^XZ');
    return buffer.toString();
  }

  /// Generates a Leather / Textile Roll Identification Tag
  String generateLeatherTextileRollTag({
    required String productName,
    required String tanneryLot,
    required String hideGrade,
    required double surfaceAreaSqFt,
    required String thicknessOz,
    required String sku,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('^XA');
    buffer.writeln('^PW609');
    buffer.writeln('^LL406');
    buffer.writeln('^FO20,20^GB569,366,3^FS');
    buffer.writeln('^FO40,40^A0N,30,30^FDLEATHER & TEXTILE LOT CERTIFICATE^FS');
    buffer.writeln('^FO40,85^A0N,26,26^FD$productName^FS');
    buffer.writeln('^FO40,125^A0N,22,22^FDTANNERY LOT: $tanneryLot • GRADE: $hideGrade^FS');
    buffer.writeln('^FO40,155^A0N,22,22^FDAREA: ${surfaceAreaSqFt.toStringAsFixed(1)} SQ FT • THICKNESS: $thicknessOz^FS');
    buffer.writeln('^FO40,200^BY2,2,70^BCN,70,Y,N,N^FD$sku^FS');
    buffer.writeln('^XZ');
    return buffer.toString();
  }
}
