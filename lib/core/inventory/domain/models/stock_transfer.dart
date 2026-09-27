import 'package:flutter/material.dart';

/// Status of an Inter-Warehouse Stock Transfer
enum TransferStatus {
  draft,
  requested,
  approved,
  inTransit,
  completed,
  cancelled,
}

extension TransferStatusExtension on TransferStatus {
  String get displayName {
    switch (this) {
      case TransferStatus.draft:
        return 'Draft';
      case TransferStatus.requested:
        return 'Requested';
      case TransferStatus.approved:
        return 'Approved';
      case TransferStatus.inTransit:
        return 'In-Transit';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TransferStatus.draft:
        return const Color(0xFF64748B);
      case TransferStatus.requested:
        return const Color(0xFFF59E0B);
      case TransferStatus.approved:
        return const Color(0xFF3B82F6);
      case TransferStatus.inTransit:
        return const Color(0xFF8B5CF6);
      case TransferStatus.completed:
        return const Color(0xFF10B981);
      case TransferStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}

/// Item within a stock transfer
class StockTransferItem {
  final String productId;
  final String productName;
  final String sku;
  final double quantity;
  final String uom;
  final String originBin;
  final String? destinationBin;

  const StockTransferItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.uom,
    required this.originBin,
    this.destinationBin,
  });

  StockTransferItem copyWith({
    String? productId,
    String? productName,
    String? sku,
    double? quantity,
    String? uom,
    String? originBin,
    String? destinationBin,
  }) {
    return StockTransferItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      uom: uom ?? this.uom,
      originBin: originBin ?? this.originBin,
      destinationBin: destinationBin ?? this.destinationBin,
    );
  }
}

/// Full Inter-Warehouse Stock Transfer Document
class StockTransfer {
  final String transferId;
  final String transferNumber; // e.g. TR-2026-001
  final String originWarehouseId;
  final String originWarehouseName;
  final String destinationWarehouseId;
  final String destinationWarehouseName;
  final List<StockTransferItem> items;
  final TransferStatus status;
  final String? carrier;
  final String? trackingNumber;
  final String? notes;
  final String requestedBy;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime? dispatchedAt;
  final DateTime? receivedAt;

  const StockTransfer({
    required this.transferId,
    required this.transferNumber,
    required this.originWarehouseId,
    required this.originWarehouseName,
    required this.destinationWarehouseId,
    required this.destinationWarehouseName,
    required this.items,
    required this.status,
    this.carrier,
    this.trackingNumber,
    this.notes,
    required this.requestedBy,
    this.approvedBy,
    required this.createdAt,
    this.dispatchedAt,
    this.receivedAt,
  });

  StockTransfer copyWith({
    String? transferId,
    String? transferNumber,
    String? originWarehouseId,
    String? originWarehouseName,
    String? destinationWarehouseId,
    String? destinationWarehouseName,
    List<StockTransferItem>? items,
    TransferStatus? status,
    String? carrier,
    String? trackingNumber,
    String? notes,
    String? requestedBy,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? dispatchedAt,
    DateTime? receivedAt,
  }) {
    return StockTransfer(
      transferId: transferId ?? this.transferId,
      transferNumber: transferNumber ?? this.transferNumber,
      originWarehouseId: originWarehouseId ?? this.originWarehouseId,
      originWarehouseName: originWarehouseName ?? this.originWarehouseName,
      destinationWarehouseId: destinationWarehouseId ?? this.destinationWarehouseId,
      destinationWarehouseName: destinationWarehouseName ?? this.destinationWarehouseName,
      items: items ?? this.items,
      status: status ?? this.status,
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      requestedBy: requestedBy ?? this.requestedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
