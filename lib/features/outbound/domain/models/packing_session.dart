import 'package:flutter/foundation.dart';

enum PackingStatus {
  inProgress,
  sealed,
  shippingLabelGenerated,
  dispatched,
}

@immutable
class PackedItem {
  final String productId;
  final String productName;
  final String sku;
  final String barcode;
  final double quantity;
  final String uom;
  final DateTime scannedAt;

  const PackedItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.uom,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'barcode': barcode,
        'quantity': quantity,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory PackedItem.fromJson(Map<String, dynamic> json) => PackedItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        sku: json['sku'] as String,
        barcode: json['barcode'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        uom: json['uom'] as String,
        scannedAt: DateTime.parse(json['scannedAt'] as String),
      );
}

@immutable
class PackingSession {
  final String id;
  final String orderId;
  final String soNumber;
  final String customerName;
  final String destination;
  final String packerName;
  final PackingStatus status;
  final List<PackedItem> scannedItems;
  final int boxCount;
  final double totalWeightKg;
  final String? trackingNumber;
  final String? shippingCarrier;
  final String? magicTrackingUrl;
  final DateTime startedAt;
  final DateTime? completedAt;

  const PackingSession({
    required this.id,
    required this.orderId,
    required this.soNumber,
    required this.customerName,
    required this.destination,
    required this.packerName,
    this.status = PackingStatus.inProgress,
    this.scannedItems = const [],
    this.boxCount = 1,
    this.totalWeightKg = 0.0,
    this.trackingNumber,
    this.shippingCarrier,
    this.magicTrackingUrl,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => status == PackingStatus.dispatched || status == PackingStatus.shippingLabelGenerated;

  PackingSession copyWith({
    String? id,
    String? orderId,
    String? soNumber,
    String? customerName,
    String? destination,
    String? packerName,
    PackingStatus? status,
    List<PackedItem>? scannedItems,
    int? boxCount,
    double? totalWeightKg,
    String? trackingNumber,
    String? shippingCarrier,
    String? magicTrackingUrl,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return PackingSession(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      soNumber: soNumber ?? this.soNumber,
      customerName: customerName ?? this.customerName,
      destination: destination ?? this.destination,
      packerName: packerName ?? this.packerName,
      status: status ?? this.status,
      scannedItems: scannedItems ?? this.scannedItems,
      boxCount: boxCount ?? this.boxCount,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shippingCarrier: shippingCarrier ?? this.shippingCarrier,
      magicTrackingUrl: magicTrackingUrl ?? this.magicTrackingUrl,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'soNumber': soNumber,
        'customerName': customerName,
        'destination': destination,
        'packerName': packerName,
        'status': status.name,
        'scannedItems': scannedItems.map((i) => i.toJson()).toList(),
        'boxCount': boxCount,
        'totalWeightKg': totalWeightKg,
        'trackingNumber': trackingNumber,
        'shippingCarrier': shippingCarrier,
        'magicTrackingUrl': magicTrackingUrl,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory PackingSession.fromJson(Map<String, dynamic> json) => PackingSession(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        soNumber: json['soNumber'] as String,
        customerName: json['customerName'] as String,
        destination: json['destination'] as String,
        packerName: json['packerName'] as String,
        status: PackingStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PackingStatus.inProgress,
        ),
        scannedItems: (json['scannedItems'] as List? ?? [])
            .map((i) => PackedItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        boxCount: json['boxCount'] as int? ?? 1,
        totalWeightKg: (json['totalWeightKg'] as num?)?.toDouble() ?? 0.0,
        trackingNumber: json['trackingNumber'] as String?,
        shippingCarrier: json['shippingCarrier'] as String?,
        magicTrackingUrl: json['magicTrackingUrl'] as String?,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}
