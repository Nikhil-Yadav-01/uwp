import 'package:flutter/foundation.dart';

enum OutboundStatus {
  pending,
  allocated,
  waveAssigned,
  picking,
  picked,
  packing,
  packed,
  shipped,
  delivered,
  cancelled,
}

extension OutboundStatusExtension on OutboundStatus {
  String get label {
    switch (this) {
      case OutboundStatus.pending:
        return 'Pending';
      case OutboundStatus.allocated:
        return 'Allocated';
      case OutboundStatus.waveAssigned:
        return 'Wave Assigned';
      case OutboundStatus.picking:
        return 'Picking';
      case OutboundStatus.picked:
        return 'Picked';
      case OutboundStatus.packing:
        return 'Packing';
      case OutboundStatus.packed:
        return 'Packed';
      case OutboundStatus.shipped:
        return 'Shipped';
      case OutboundStatus.delivered:
        return 'Delivered';
      case OutboundStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum OrderPriority {
  standard,
  rush,
  emergencyCrashCart, // Emergency Hospital Crash Cart replenishment
}

enum CustomerType {
  b2bWholesale,
  retailStore,
  hospitalWard,
  barCounter,
}

@immutable
class SalesOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final double requestedQty;
  final double pickedQty;
  final double packedQty;
  final double unitPrice;
  final String uom;
  final Map<String, dynamic> customAttributes; // e.g., preferred batch, size/color variant

  const SalesOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.requestedQty,
    this.pickedQty = 0.0,
    this.packedQty = 0.0,
    required this.unitPrice,
    required this.uom,
    this.customAttributes = const {},
  });

  double get subtotal => requestedQty * unitPrice;
  bool get isFullyPicked => pickedQty >= requestedQty;
  bool get isFullyPacked => packedQty >= requestedQty;

  SalesOrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    double? requestedQty,
    double? pickedQty,
    double? packedQty,
    double? unitPrice,
    String? uom,
    Map<String, dynamic>? customAttributes,
  }) {
    return SalesOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      requestedQty: requestedQty ?? this.requestedQty,
      pickedQty: pickedQty ?? this.pickedQty,
      packedQty: packedQty ?? this.packedQty,
      unitPrice: unitPrice ?? this.unitPrice,
      uom: uom ?? this.uom,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'requestedQty': requestedQty,
        'pickedQty': pickedQty,
        'packedQty': packedQty,
        'unitPrice': unitPrice,
        'uom': uom,
        'customAttributes': customAttributes,
      };

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) => SalesOrderItem(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        sku: json['sku'] as String,
        requestedQty: (json['requestedQty'] as num).toDouble(),
        pickedQty: (json['pickedQty'] as num?)?.toDouble() ?? 0.0,
        packedQty: (json['packedQty'] as num?)?.toDouble() ?? 0.0,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        uom: json['uom'] as String,
        customAttributes: Map<String, dynamic>.from(json['customAttributes'] as Map? ?? {}),
      );
}

@immutable
class SalesOrder {
  final String id;
  final String soNumber;
  final String customerName;
  final CustomerType customerType;
  final String destinationWardOrAddress;
  final DateTime orderDate;
  final DateTime? requiredDeliveryDate;
  final OrderPriority priority;
  final OutboundStatus status;
  final List<SalesOrderItem> items;
  final String archetypeId;
  final String? assignedWaveId;
  final String? notes;

  const SalesOrder({
    required this.id,
    required this.soNumber,
    required this.customerName,
    required this.customerType,
    required this.destinationWardOrAddress,
    required this.orderDate,
    this.requiredDeliveryDate,
    this.priority = OrderPriority.standard,
    required this.status,
    required this.items,
    required this.archetypeId,
    this.assignedWaveId,
    this.notes,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalRequestedUnits => items.fold(0.0, (sum, item) => sum + item.requestedQty);
  double get totalPickedUnits => items.fold(0.0, (sum, item) => sum + item.pickedQty);
  double get totalPackedUnits => items.fold(0.0, (sum, item) => sum + item.packedQty);
  double get fulfillmentProgress => totalRequestedUnits == 0 ? 0.0 : (totalPackedUnits / totalRequestedUnits).clamp(0.0, 1.0);

  SalesOrder copyWith({
    String? id,
    String? soNumber,
    String? customerName,
    CustomerType? customerType,
    String? destinationWardOrAddress,
    DateTime? orderDate,
    DateTime? requiredDeliveryDate,
    OrderPriority? priority,
    OutboundStatus? status,
    List<SalesOrderItem>? items,
    String? archetypeId,
    String? assignedWaveId,
    String? notes,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      soNumber: soNumber ?? this.soNumber,
      customerName: customerName ?? this.customerName,
      customerType: customerType ?? this.customerType,
      destinationWardOrAddress: destinationWardOrAddress ?? this.destinationWardOrAddress,
      orderDate: orderDate ?? this.orderDate,
      requiredDeliveryDate: requiredDeliveryDate ?? this.requiredDeliveryDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      items: items ?? this.items,
      archetypeId: archetypeId ?? this.archetypeId,
      assignedWaveId: assignedWaveId ?? this.assignedWaveId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'soNumber': soNumber,
        'customerName': customerName,
        'customerType': customerType.name,
        'destinationWardOrAddress': destinationWardOrAddress,
        'orderDate': orderDate.toIso8601String(),
        'requiredDeliveryDate': requiredDeliveryDate?.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'items': items.map((i) => i.toJson()).toList(),
        'archetypeId': archetypeId,
        'assignedWaveId': assignedWaveId,
        'notes': notes,
      };

  factory SalesOrder.fromJson(Map<String, dynamic> json) => SalesOrder(
        id: json['id'] as String,
        soNumber: json['soNumber'] as String,
        customerName: json['customerName'] as String,
        customerType: CustomerType.values.firstWhere(
          (e) => e.name == json['customerType'],
          orElse: () => CustomerType.b2bWholesale,
        ),
        destinationWardOrAddress: json['destinationWardOrAddress'] as String,
        orderDate: DateTime.parse(json['orderDate'] as String),
        requiredDeliveryDate: json['requiredDeliveryDate'] != null
            ? DateTime.parse(json['requiredDeliveryDate'] as String)
            : null,
        priority: OrderPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => OrderPriority.standard,
        ),
        status: OutboundStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => OutboundStatus.pending,
        ),
        items: (json['items'] as List)
            .map((i) => SalesOrderItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        archetypeId: json['archetypeId'] as String,
        assignedWaveId: json['assignedWaveId'] as String?,
        notes: json['notes'] as String?,
      );
}
