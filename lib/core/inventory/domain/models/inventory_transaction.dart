import 'package:flutter/material.dart';

/// Transaction movement types representing every physical and logical inventory mutation.
enum InventoryTransactionType {
  purchaseReceipt,
  putaway,
  sale,
  pick,
  transferOut,
  transferIn,
  adjustmentIn,
  adjustmentOut,
  damage,
  returnOrder,
}

extension InventoryTransactionTypeExtension on InventoryTransactionType {
  String get displayName {
    switch (this) {
      case InventoryTransactionType.purchaseReceipt:
        return 'Purchase Receipt';
      case InventoryTransactionType.putaway:
        return 'Put-Away';
      case InventoryTransactionType.sale:
        return 'POS / Direct Sale';
      case InventoryTransactionType.pick:
        return 'Wave Picking';
      case InventoryTransactionType.transferOut:
        return 'Transfer (Outbound)';
      case InventoryTransactionType.transferIn:
        return 'Transfer (Inbound)';
      case InventoryTransactionType.adjustmentIn:
        return 'Adjustment (+ Extra)';
      case InventoryTransactionType.adjustmentOut:
        return 'Adjustment (- Missing)';
      case InventoryTransactionType.damage:
        return 'Damaged / Scrapped';
      case InventoryTransactionType.returnOrder:
        return 'Customer Return';
    }
  }

  Color get badgeColor {
    switch (this) {
      case InventoryTransactionType.purchaseReceipt:
      case InventoryTransactionType.transferIn:
      case InventoryTransactionType.adjustmentIn:
      case InventoryTransactionType.returnOrder:
        return const Color(0xFF10B981); // Green (+)
      case InventoryTransactionType.putaway:
        return const Color(0xFF0EA5E9); // Sky blue
      case InventoryTransactionType.sale:
      case InventoryTransactionType.pick:
      case InventoryTransactionType.transferOut:
      case InventoryTransactionType.adjustmentOut:
        return const Color(0xFFF59E0B); // Amber (-)
      case InventoryTransactionType.damage:
        return const Color(0xFFEF4444); // Red
    }
  }

  bool get isAddition {
    switch (this) {
      case InventoryTransactionType.purchaseReceipt:
      case InventoryTransactionType.transferIn:
      case InventoryTransactionType.adjustmentIn:
      case InventoryTransactionType.returnOrder:
        return true;
      case InventoryTransactionType.putaway:
      case InventoryTransactionType.sale:
      case InventoryTransactionType.pick:
      case InventoryTransactionType.transferOut:
      case InventoryTransactionType.adjustmentOut:
      case InventoryTransactionType.damage:
        return false;
    }
  }
}

/// Immutable Stock Movement Ledger Record
class InventoryTransaction {
  final String transactionId;
  final String productId;
  final String productName;
  final String sku;
  final String warehouseId;
  final String warehouseName;
  final String locationId; // e.g. BIN-A01-05
  final InventoryTransactionType transactionType;
  final double quantity;
  final String uom;
  final double balanceAfter;
  final String referenceType; // e.g. PO, SO, TRANSFER, QC, POS
  final String referenceId;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  const InventoryTransaction({
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.warehouseId,
    required this.warehouseName,
    required this.locationId,
    required this.transactionType,
    required this.quantity,
    required this.uom,
    required this.balanceAfter,
    required this.referenceType,
    required this.referenceId,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  InventoryTransaction copyWith({
    String? transactionId,
    String? productId,
    String? productName,
    String? sku,
    String? warehouseId,
    String? warehouseName,
    String? locationId,
    InventoryTransactionType? transactionType,
    double? quantity,
    String? uom,
    double? balanceAfter,
    String? referenceType,
    String? referenceId,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return InventoryTransaction(
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      locationId: locationId ?? this.locationId,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      uom: uom ?? this.uom,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
