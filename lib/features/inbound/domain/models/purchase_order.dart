import 'package:flutter/foundation.dart';

enum InboundStatus {
  draft,
  approved,
  inTransit,
  atDock,
  receiving,
  qcPending,
  qcPassed,
  qcFailed,
  putawayReady,
  completed,
  cancelled,
}

extension InboundStatusExtension on InboundStatus {
  String get label {
    switch (this) {
      case InboundStatus.draft:
        return 'Draft';
      case InboundStatus.approved:
        return 'Approved';
      case InboundStatus.inTransit:
        return 'In Transit';
      case InboundStatus.atDock:
        return 'At Dock';
      case InboundStatus.receiving:
        return 'Receiving';
      case InboundStatus.qcPending:
        return 'QC Pending';
      case InboundStatus.qcPassed:
        return 'QC Passed';
      case InboundStatus.qcFailed:
        return 'QC Failed';
      case InboundStatus.putawayReady:
        return 'Putaway Ready';
      case InboundStatus.completed:
        return 'Completed';
      case InboundStatus.cancelled:
        return 'Cancelled';
    }
  }
}

@immutable
class PurchaseOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final double orderedQty;
  final double receivedQty;
  final double unitPrice;
  final String uom;
  final Map<String, dynamic> customAttributes;

  const PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.orderedQty,
    this.receivedQty = 0.0,
    required this.unitPrice,
    required this.uom,
    this.customAttributes = const {},
  });

  double get subtotal => orderedQty * unitPrice;
  bool get isFullyReceived => receivedQty >= orderedQty;
  double get remainingQty => (orderedQty - receivedQty).clamp(0.0, double.infinity);

  PurchaseOrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    double? orderedQty,
    double? receivedQty,
    double? unitPrice,
    String? uom,
    Map<String, dynamic>? customAttributes,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      orderedQty: orderedQty ?? this.orderedQty,
      receivedQty: receivedQty ?? this.receivedQty,
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
        'orderedQty': orderedQty,
        'receivedQty': receivedQty,
        'unitPrice': unitPrice,
        'uom': uom,
        'customAttributes': customAttributes,
      };

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => PurchaseOrderItem(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        sku: json['sku'] as String,
        orderedQty: (json['orderedQty'] as num).toDouble(),
        receivedQty: (json['receivedQty'] as num?)?.toDouble() ?? 0.0,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        uom: json['uom'] as String,
        customAttributes: Map<String, dynamic>.from(json['customAttributes'] as Map? ?? {}),
      );
}

@immutable
class PurchaseOrder {
  final String id;
  final String poNumber;
  final String vendorName;
  final String? vendorEmail;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final InboundStatus status;
  final List<PurchaseOrderItem> items;
  final String archetypeId;
  final String? notes;
  final String? receivingDockId;
  final DateTime? actualArrivalDate;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.vendorName,
    this.vendorEmail,
    required this.orderDate,
    this.expectedDeliveryDate,
    required this.status,
    required this.items,
    required this.archetypeId,
    this.notes,
    this.receivingDockId,
    this.actualArrivalDate,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalOrderedUnits => items.fold(0.0, (sum, item) => sum + item.orderedQty);
  double get totalReceivedUnits => items.fold(0.0, (sum, item) => sum + item.receivedQty);
  double get receivingProgress => totalOrderedUnits == 0 ? 0.0 : (totalReceivedUnits / totalOrderedUnits).clamp(0.0, 1.0);

  PurchaseOrder copyWith({
    String? id,
    String? poNumber,
    String? vendorName,
    String? vendorEmail,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    InboundStatus? status,
    List<PurchaseOrderItem>? items,
    String? archetypeId,
    String? notes,
    String? receivingDockId,
    DateTime? actualArrivalDate,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      vendorName: vendorName ?? this.vendorName,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      items: items ?? this.items,
      archetypeId: archetypeId ?? this.archetypeId,
      notes: notes ?? this.notes,
      receivingDockId: receivingDockId ?? this.receivingDockId,
      actualArrivalDate: actualArrivalDate ?? this.actualArrivalDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'poNumber': poNumber,
        'vendorName': vendorName,
        'vendorEmail': vendorEmail,
        'orderDate': orderDate.toIso8601String(),
        'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
        'status': status.name,
        'items': items.map((i) => i.toJson()).toList(),
        'archetypeId': archetypeId,
        'notes': notes,
        'receivingDockId': receivingDockId,
        'actualArrivalDate': actualArrivalDate?.toIso8601String(),
      };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
        id: json['id'] as String,
        poNumber: json['poNumber'] as String,
        vendorName: json['vendorName'] as String,
        vendorEmail: json['vendorEmail'] as String?,
        orderDate: DateTime.parse(json['orderDate'] as String),
        expectedDeliveryDate: json['expectedDeliveryDate'] != null
            ? DateTime.parse(json['expectedDeliveryDate'] as String)
            : null,
        status: InboundStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => InboundStatus.draft,
        ),
        items: (json['items'] as List)
            .map((i) => PurchaseOrderItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        archetypeId: json['archetypeId'] as String,
        notes: json['notes'] as String?,
        receivingDockId: json['receivingDockId'] as String?,
        actualArrivalDate: json['actualArrivalDate'] != null
            ? DateTime.parse(json['actualArrivalDate'] as String)
            : null,
      );
}
