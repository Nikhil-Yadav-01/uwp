import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ReturnReason {
  damagedInTransit,
  wrongItemShipped,
  customerReturn,
  defectiveItem,
  undeliveredRto,
}

extension ReturnReasonExtension on ReturnReason {
  String get label {
    switch (this) {
      case ReturnReason.damagedInTransit:
        return 'Damaged in Transit';
      case ReturnReason.wrongItemShipped:
        return 'Wrong Item Shipped';
      case ReturnReason.customerReturn:
        return 'Customer Return (Size/Change of Mind)';
      case ReturnReason.defectiveItem:
        return 'Defective / Quality Issue';
      case ReturnReason.undeliveredRto:
        return 'RTO (Undelivered / Address Issue)';
    }
  }
}

enum ReturnStatus {
  pending,
  approved,
  received,
  restocked,
  scrapped,
}

extension ReturnStatusExtension on ReturnStatus {
  String get label {
    switch (this) {
      case ReturnStatus.pending:
        return 'Pending Review';
      case ReturnStatus.approved:
        return 'Approved / In-Transit';
      case ReturnStatus.received:
        return 'Received at Dock';
      case ReturnStatus.restocked:
        return 'Restocked to Bin';
      case ReturnStatus.scrapped:
        return 'Scrapped / RMA Return';
    }
  }

  Color get color {
    switch (this) {
      case ReturnStatus.pending:
        return AppColors.warning;
      case ReturnStatus.approved:
        return AppColors.info;
      case ReturnStatus.received:
        return const Color(0xFF6366F1); // Indigo
      case ReturnStatus.restocked:
        return AppColors.success;
      case ReturnStatus.scrapped:
        return AppColors.error;
    }
  }
}

class ReturnRequest {
  final String id;
  final String returnNumber; // e.g. RTN-0012
  final String salesOrderNumber; // e.g. SO-0456
  final String customerName;
  final String sku;
  final String productName;
  final int quantity;
  final ReturnReason reason;
  final ReturnStatus status;
  final String? assignedBinLocation;
  final String? trackingNumber;
  final String notes;
  final DateTime createdAt;

  const ReturnRequest({
    required this.id,
    required this.returnNumber,
    required this.salesOrderNumber,
    required this.customerName,
    required this.sku,
    required this.productName,
    required this.quantity,
    required this.reason,
    this.status = ReturnStatus.pending,
    this.assignedBinLocation,
    this.trackingNumber,
    this.notes = '',
    required this.createdAt,
  });

  ReturnRequest copyWith({
    String? id,
    String? returnNumber,
    String? salesOrderNumber,
    String? customerName,
    String? sku,
    String? productName,
    int? quantity,
    ReturnReason? reason,
    ReturnStatus? status,
    String? assignedBinLocation,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return ReturnRequest(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      salesOrderNumber: salesOrderNumber ?? this.salesOrderNumber,
      customerName: customerName ?? this.customerName,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      assignedBinLocation: assignedBinLocation ?? this.assignedBinLocation,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
