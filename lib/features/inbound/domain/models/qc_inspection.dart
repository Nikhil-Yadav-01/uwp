import 'package:flutter/foundation.dart';

enum QcStatus {
  pending,
  passed,
  passedWithDiscrepancy,
  quarantined,
  rejected,
}

enum DefectDisposition {
  acceptWithDiscount,
  quarantineHold,
  returnToVendor,
  scrapDeduct,
}

@immutable
class QcItemResult {
  final String productId;
  final String productName;
  final String sku;
  final double inspectedQty;
  final double passedQty;
  final double rejectedQty;
  final String? defectReason;
  final DefectDisposition disposition;
  final List<String> defectPhotoUrls;
  final Map<String, dynamic> testMetrics; // e.g., temperature reading, hide thickness, voltage test

  const QcItemResult({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.inspectedQty,
    required this.passedQty,
    this.rejectedQty = 0.0,
    this.defectReason,
    this.disposition = DefectDisposition.acceptWithDiscount,
    this.defectPhotoUrls = const [],
    this.testMetrics = const {},
  });

  bool get isDefective => rejectedQty > 0;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'inspectedQty': inspectedQty,
        'passedQty': passedQty,
        'rejectedQty': rejectedQty,
        'defectReason': defectReason,
        'disposition': disposition.name,
        'defectPhotoUrls': defectPhotoUrls,
        'testMetrics': testMetrics,
      };

  factory QcItemResult.fromJson(Map<String, dynamic> json) => QcItemResult(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        sku: json['sku'] as String,
        inspectedQty: (json['inspectedQty'] as num).toDouble(),
        passedQty: (json['passedQty'] as num).toDouble(),
        rejectedQty: (json['rejectedQty'] as num?)?.toDouble() ?? 0.0,
        defectReason: json['defectReason'] as String?,
        disposition: DefectDisposition.values.firstWhere(
          (e) => e.name == json['disposition'],
          orElse: () => DefectDisposition.acceptWithDiscount,
        ),
        defectPhotoUrls: List<String>.from(json['defectPhotoUrls'] as List? ?? []),
        testMetrics: Map<String, dynamic>.from(json['testMetrics'] as Map? ?? {}),
      );
}

@immutable
class QcInspectionReport {
  final String id;
  final String poId;
  final String poNumber;
  final String inspectorName;
  final String? witnessName; // For narcotics, hazardous chemicals, high-value electronics
  final DateTime inspectionDate;
  final QcStatus status;
  final List<QcItemResult> itemResults;
  final String? overallNotes;
  final bool requiresDualSignoff;
  final bool isDualSigned;

  const QcInspectionReport({
    required this.id,
    required this.poId,
    required this.poNumber,
    required this.inspectorName,
    this.witnessName,
    required this.inspectionDate,
    required this.status,
    required this.itemResults,
    this.overallNotes,
    this.requiresDualSignoff = false,
    this.isDualSigned = false,
  });

  double get totalInspectedUnits => itemResults.fold(0.0, (s, i) => s + i.inspectedQty);
  double get totalPassedUnits => itemResults.fold(0.0, (s, i) => s + i.passedQty);
  double get totalRejectedUnits => itemResults.fold(0.0, (s, i) => s + i.rejectedQty);
  double get passRate => totalInspectedUnits == 0 ? 1.0 : (totalPassedUnits / totalInspectedUnits);

  QcInspectionReport copyWith({
    String? id,
    String? poId,
    String? poNumber,
    String? inspectorName,
    String? witnessName,
    DateTime? inspectionDate,
    QcStatus? status,
    List<QcItemResult>? itemResults,
    String? overallNotes,
    bool? requiresDualSignoff,
    bool? isDualSigned,
  }) {
    return QcInspectionReport(
      id: id ?? this.id,
      poId: poId ?? this.poId,
      poNumber: poNumber ?? this.poNumber,
      inspectorName: inspectorName ?? this.inspectorName,
      witnessName: witnessName ?? this.witnessName,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      status: status ?? this.status,
      itemResults: itemResults ?? this.itemResults,
      overallNotes: overallNotes ?? this.overallNotes,
      requiresDualSignoff: requiresDualSignoff ?? this.requiresDualSignoff,
      isDualSigned: isDualSigned ?? this.isDualSigned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'poId': poId,
        'poNumber': poNumber,
        'inspectorName': inspectorName,
        'witnessName': witnessName,
        'inspectionDate': inspectionDate.toIso8601String(),
        'status': status.name,
        'itemResults': itemResults.map((i) => i.toJson()).toList(),
        'overallNotes': overallNotes,
        'requiresDualSignoff': requiresDualSignoff,
        'isDualSigned': isDualSigned,
      };

  factory QcInspectionReport.fromJson(Map<String, dynamic> json) => QcInspectionReport(
        id: json['id'] as String,
        poId: json['poId'] as String,
        poNumber: json['poNumber'] as String,
        inspectorName: json['inspectorName'] as String,
        witnessName: json['witnessName'] as String?,
        inspectionDate: DateTime.parse(json['inspectionDate'] as String),
        status: QcStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => QcStatus.pending,
        ),
        itemResults: (json['itemResults'] as List)
            .map((i) => QcItemResult.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        overallNotes: json['overallNotes'] as String?,
        requiresDualSignoff: json['requiresDualSignoff'] as bool? ?? false,
        isDualSigned: json['isDualSigned'] as bool? ?? false,
      );
}
