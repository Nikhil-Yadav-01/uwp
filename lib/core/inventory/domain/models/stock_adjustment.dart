import 'package:flutter/material.dart';

/// Reason codes for stock reconciliation / adjustments
enum AdjustmentReason {
  damaged,
  expired,
  missing,
  cycleCountDiscrepancy,
  foundExtra,
  scrapLoss,
}

extension AdjustmentReasonExtension on AdjustmentReason {
  String get displayName {
    switch (this) {
      case AdjustmentReason.damaged:
        return 'Damaged Goods';
      case AdjustmentReason.expired:
        return 'Shelf-Life Expired';
      case AdjustmentReason.missing:
        return 'Missing / Unaccounted';
      case AdjustmentReason.cycleCountDiscrepancy:
        return 'Cycle Count Discrepancy';
      case AdjustmentReason.foundExtra:
        return 'Found Extra / Surplus';
      case AdjustmentReason.scrapLoss:
        return 'Manufacturing Scrap / Cut Loss';
    }
  }

  IconData get icon {
    switch (this) {
      case AdjustmentReason.damaged:
        return Icons.broken_image_outlined;
      case AdjustmentReason.expired:
        return Icons.timer_off_outlined;
      case AdjustmentReason.missing:
        return Icons.search_off_outlined;
      case AdjustmentReason.cycleCountDiscrepancy:
        return Icons.checklist_rtl_outlined;
      case AdjustmentReason.foundExtra:
        return Icons.add_circle_outline;
      case AdjustmentReason.scrapLoss:
        return Icons.content_cut_outlined;
    }
  }
}

/// Stock Adjustment Record
class StockAdjustment {
  final String adjustmentId;
  final String adjustmentNumber; // e.g. ADJ-2026-001
  final String warehouseId;
  final String warehouseName;
  final String locationId; // Bin
  final String productId;
  final String productName;
  final String sku;
  final double systemQuantity;
  final double physicalQuantity;
  final double varianceQuantity; // physicalQuantity - systemQuantity
  final String uom;
  final AdjustmentReason reason;
  final String? notes;
  final String createdBy;
  final String? approvedBy;
  final DateTime createdAt;

  const StockAdjustment({
    required this.adjustmentId,
    required this.adjustmentNumber,
    required this.warehouseId,
    required this.warehouseName,
    required this.locationId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.systemQuantity,
    required this.physicalQuantity,
    required this.varianceQuantity,
    required this.uom,
    required this.reason,
    this.notes,
    required this.createdBy,
    this.approvedBy,
    required this.createdAt,
  });

  StockAdjustment copyWith({
    String? adjustmentId,
    String? adjustmentNumber,
    String? warehouseId,
    String? warehouseName,
    String? locationId,
    String? productId,
    String? productName,
    String? sku,
    double? systemQuantity,
    double? physicalQuantity,
    double? varianceQuantity,
    String? uom,
    AdjustmentReason? reason,
    String? notes,
    String? createdBy,
    String? approvedBy,
    DateTime? createdAt,
  }) {
    return StockAdjustment(
      adjustmentId: adjustmentId ?? this.adjustmentId,
      adjustmentNumber: adjustmentNumber ?? this.adjustmentNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      locationId: locationId ?? this.locationId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      physicalQuantity: physicalQuantity ?? this.physicalQuantity,
      varianceQuantity: varianceQuantity ?? this.varianceQuantity,
      uom: uom ?? this.uom,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
