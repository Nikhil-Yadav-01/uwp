import 'dart:ui';
import '../models/scanned_barcode.dart';

/// Engine that processes camera batch barcodes concurrently,
/// applies debounce deduplication, and matches against expected catalog/picklist items.
class MultiBarcodeBatchEngine {
  final Map<String, DateTime> _recentScans = {};
  final Duration debounceWindow;

  MultiBarcodeBatchEngine({
    this.debounceWindow = const Duration(milliseconds: 1200),
  });

  /// Processes a burst batch of raw barcodes captured in a single camera AR frame.
  List<ScannedBarcode> processBatch({
    required List<RawDetectedBarcode> detectedBarcodes,
    Set<String> expectedCodes = const {},
    Set<String> alreadyProcessedCodes = const {},
  }) {
    final now = DateTime.now();
    _cleanOldEntries(now);

    final List<ScannedBarcode> result = [];

    for (final raw in detectedBarcodes) {
      final code = raw.rawValue.trim();
      if (code.isEmpty) continue;

      // 1. Debounce check
      final lastSeen = _recentScans[code];
      final isDebounced = lastSeen != null && now.difference(lastSeen) < debounceWindow;
      if (isDebounced) {
        continue;
      }
      _recentScans[code] = now;

      // 2. Match evaluation
      BarcodeMatchStatus matchStatus;
      if (alreadyProcessedCodes.contains(code)) {
        matchStatus = BarcodeMatchStatus.duplicate;
      } else if (expectedCodes.isNotEmpty) {
        final matches = expectedCodes.any(
          (exp) => exp.toLowerCase() == code.toLowerCase() || code.toLowerCase().contains(exp.toLowerCase()),
        );
        matchStatus = matches ? BarcodeMatchStatus.matched : BarcodeMatchStatus.unmatched;
      } else {
        matchStatus = BarcodeMatchStatus.matched; // Open scan mode
      }

      result.add(
        ScannedBarcode(
          id: 'BC-${now.microsecondsSinceEpoch}-${result.length}',
          rawCode: code,
          symbology: raw.symbology,
          timestamp: now,
          boundingBox: raw.normalizedRect,
          matchStatus: matchStatus,
        ),
      );
    }

    return result;
  }

  void _cleanOldEntries(DateTime now) {
    _recentScans.removeWhere((_, time) => now.difference(time) > const Duration(seconds: 10));
  }

  void clearHistory() {
    _recentScans.clear();
  }
}

class RawDetectedBarcode {
  final String rawValue;
  final BarcodeSymbology symbology;
  final Rect? normalizedRect;

  const RawDetectedBarcode({
    required this.rawValue,
    this.symbology = BarcodeSymbology.code128,
    this.normalizedRect,
  });
}
