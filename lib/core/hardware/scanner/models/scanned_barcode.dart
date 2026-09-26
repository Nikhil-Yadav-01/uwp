import 'package:flutter/material.dart';

enum BarcodeSymbology {
  code128,
  ean13,
  upcA,
  qrCode,
  dataMatrix,
  code39,
  aztec,
}

enum BarcodeMatchStatus {
  matched,     // Matches an expected pick/pack line item
  unmatched,   // Valid barcode but not in current batch
  duplicate,   // Already scanned in this session
  quarantined, // Flagged for defect or recall
}

@immutable
class ScannedBarcode {
  final String id;
  final String rawCode;
  final BarcodeSymbology symbology;
  final DateTime timestamp;
  final Rect? boundingBox; // Normalized camera coordinates (0.0 to 1.0)
  final BarcodeMatchStatus matchStatus;
  final String? matchedSku;
  final String? matchedProductName;

  const ScannedBarcode({
    required this.id,
    required this.rawCode,
    required this.symbology,
    required this.timestamp,
    this.boundingBox,
    this.matchStatus = BarcodeMatchStatus.unmatched,
    this.matchedSku,
    this.matchedProductName,
  });

  ScannedBarcode copyWith({
    String? id,
    String? rawCode,
    BarcodeSymbology? symbology,
    DateTime? timestamp,
    Rect? boundingBox,
    BarcodeMatchStatus? matchStatus,
    String? matchedSku,
    String? matchedProductName,
  }) {
    return ScannedBarcode(
      id: id ?? this.id,
      rawCode: rawCode ?? this.rawCode,
      symbology: symbology ?? this.symbology,
      timestamp: timestamp ?? this.timestamp,
      boundingBox: boundingBox ?? this.boundingBox,
      matchStatus: matchStatus ?? this.matchStatus,
      matchedSku: matchedSku ?? this.matchedSku,
      matchedProductName: matchedProductName ?? this.matchedProductName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawCode': rawCode,
        'symbology': symbology.name,
        'timestamp': timestamp.toIso8601String(),
        'matchStatus': matchStatus.name,
        'matchedSku': matchedSku,
        'matchedProductName': matchedProductName,
      };

  factory ScannedBarcode.fromJson(Map<String, dynamic> json) => ScannedBarcode(
        id: json['id'] as String,
        rawCode: json['rawCode'] as String,
        symbology: BarcodeSymbology.values.firstWhere(
          (e) => e.name == json['symbology'],
          orElse: () => BarcodeSymbology.code128,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        matchStatus: BarcodeMatchStatus.values.firstWhere(
          (e) => e.name == json['matchStatus'],
          orElse: () => BarcodeMatchStatus.unmatched,
        ),
        matchedSku: json['matchedSku'] as String?,
        matchedProductName: json['matchedProductName'] as String?,
      );
}
