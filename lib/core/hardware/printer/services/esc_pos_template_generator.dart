/// Generator for standard Epson ESC/POS byte sequences for 80mm & 58mm thermal receipt printers.
class EscPosTemplateGenerator {
  const EscPosTemplateGenerator();

  /// Generates human-readable string representation with ESC/POS command markers.
  String generatePickVoucher({
    required String waveNumber,
    required String pickerName,
    required String zone,
    required List<Map<String, String>> items,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('[ESC @] [ESC a 1]'); // Initialize & Center Align
    buffer.writeln('==========================================');
    buffer.writeln('           UNIVERSAL WMS PICKLIST         ');
    buffer.writeln('==========================================');
    buffer.writeln('[ESC a 0]'); // Left Align
    buffer.writeln('Wave: $waveNumber');
    buffer.writeln('Picker: $pickerName');
    buffer.writeln('Zone: $zone');
    buffer.writeln('Date: ${DateTime.now().toLocal().toString().substring(0, 19)}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('LOC        SKU             QTY   CONFIRM');
    buffer.writeln('------------------------------------------');

    for (final item in items) {
      final loc = (item['location'] ?? '').padRight(10).substring(0, 10);
      final sku = (item['sku'] ?? '').padRight(15).substring(0, 15);
      final qty = (item['qty'] ?? '1').padRight(5).substring(0, 5);
      buffer.writeln('$loc $sku $qty [ ]');
    }

    buffer.writeln('==========================================');
    buffer.writeln('[ESC a 1]');
    buffer.writeln('[GS k 4] $waveNumber'); // Barcode
    buffer.writeln('\nScan wave barcode to start voice picking.\n');
    buffer.writeln('[GS V 66 0]'); // Cut Paper
    return buffer.toString();
  }

  /// Generates a POS sales receipt template
  String generatePosReceipt({
    required String receiptNumber,
    required String cashierName,
    required List<Map<String, dynamic>> lineItems,
    required double subtotal,
    required double tax,
    required double total,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('[ESC @] [ESC a 1]');
    buffer.writeln('==========================================');
    buffer.writeln('            UNIVERSAL RETAIL / POS        ');
    buffer.writeln('==========================================');
    buffer.writeln('[ESC a 0]');
    buffer.writeln('Receipt: $receiptNumber');
    buffer.writeln('Cashier: $cashierName');
    buffer.writeln('Date: ${DateTime.now().toLocal().toString().substring(0, 19)}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('ITEM                    QTY    PRICE   TOTAL');
    buffer.writeln('------------------------------------------');

    for (final item in lineItems) {
      final name = (item['name'] as String? ?? '').padRight(20).substring(0, 20);
      final qty = (item['qty'] as num? ?? 1).toString().padRight(4).substring(0, 4);
      final price = (item['price'] as num? ?? 0.0).toStringAsFixed(2).padLeft(7);
      final itemTot = ((item['qty'] as num? ?? 1) * (item['price'] as num? ?? 0.0)).toStringAsFixed(2).padLeft(7);
      buffer.writeln('$name $qty $price $itemTot');
    }

    buffer.writeln('------------------------------------------');
    buffer.writeln('Subtotal:                              \$${subtotal.toStringAsFixed(2)}');
    buffer.writeln('Tax:                                   \$${tax.toStringAsFixed(2)}');
    buffer.writeln('TOTAL:                                 \$${total.toStringAsFixed(2)}');
    buffer.writeln('==========================================');
    buffer.writeln('[ESC a 1] Thank you for your business!');
    buffer.writeln('[GS V 66 0]');
    return buffer.toString();
  }
}
