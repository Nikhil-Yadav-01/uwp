import 'package:flutter/foundation.dart';

enum StorageZoneType {
  ambient,
  coldRoomChilled, // +2°C to +8°C (Groceries, Vaccines)
  deepFrozen,      // -18°C (Meats, Cryo Pharma)
  narcoticsVault,  // Schedule II-V double-lock vault
  flammableHazmat, // Hardware lubricants, solvents
  bulkPalletRacks, // Hardware, Bulk Dry Grocery
  hangingRacks,    // Fashion, Garments
  rollRacks,       // Leather rolls, Textile bolts
  secureHighValueCage, // Mobile phones, laptops
}

enum PutawayStatus {
  pending,
  inProgress,
  completed,
}

@immutable
class PutawayTask {
  final String id;
  final String poId;
  final String poNumber;
  final String productId;
  final String productName;
  final String sku;
  final double quantity;
  final String uom;
  final String sourceDockLocation;
  final String suggestedLocation; // e.g. "Zone C - Aisle 04 - Rack 02 - Bin 11"
  final String? confirmedLocation;
  final StorageZoneType zoneType;
  final PutawayStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? assignedOperator;

  const PutawayTask({
    required this.id,
    required this.poId,
    required this.poNumber,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.uom,
    this.sourceDockLocation = 'Dock Staging Bay 01',
    required this.suggestedLocation,
    this.confirmedLocation,
    required this.zoneType,
    this.status = PutawayStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.assignedOperator,
  });

  bool get isCompleted => status == PutawayStatus.completed;

  PutawayTask copyWith({
    String? id,
    String? poId,
    String? poNumber,
    String? productId,
    String? productName,
    String? sku,
    double? quantity,
    String? uom,
    String? sourceDockLocation,
    String? suggestedLocation,
    String? confirmedLocation,
    StorageZoneType? zoneType,
    PutawayStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? assignedOperator,
  }) {
    return PutawayTask(
      id: id ?? this.id,
      poId: poId ?? this.poId,
      poNumber: poNumber ?? this.poNumber,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      uom: uom ?? this.uom,
      sourceDockLocation: sourceDockLocation ?? this.sourceDockLocation,
      suggestedLocation: suggestedLocation ?? this.suggestedLocation,
      confirmedLocation: confirmedLocation ?? this.confirmedLocation,
      zoneType: zoneType ?? this.zoneType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      assignedOperator: assignedOperator ?? this.assignedOperator,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'poId': poId,
        'poNumber': poNumber,
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'quantity': quantity,
        'uom': uom,
        'sourceDockLocation': sourceDockLocation,
        'suggestedLocation': suggestedLocation,
        'confirmedLocation': confirmedLocation,
        'zoneType': zoneType.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'assignedOperator': assignedOperator,
      };

  factory PutawayTask.fromJson(Map<String, dynamic> json) => PutawayTask(
        id: json['id'] as String,
        poId: json['poId'] as String,
        poNumber: json['poNumber'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        sku: json['sku'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        uom: json['uom'] as String,
        sourceDockLocation: json['sourceDockLocation'] as String? ?? 'Dock Staging Bay 01',
        suggestedLocation: json['suggestedLocation'] as String,
        confirmedLocation: json['confirmedLocation'] as String?,
        zoneType: StorageZoneType.values.firstWhere(
          (e) => e.name == json['zoneType'],
          orElse: () => StorageZoneType.ambient,
        ),
        status: PutawayStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PutawayStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        assignedOperator: json['assignedOperator'] as String?,
      );
}
