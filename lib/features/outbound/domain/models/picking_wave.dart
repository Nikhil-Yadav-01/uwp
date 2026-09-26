import 'package:flutter/foundation.dart';

enum WaveStatus {
  created,
  inProgress,
  completed,
}

@immutable
class PickTask {
  final String id;
  final String orderId;
  final String soNumber;
  final String productId;
  final String productName;
  final String sku;
  final String location; // e.g. "Zone A - Aisle 02 - Rack 03 - Bin 04"
  final double quantityToPick;
  final double quantityPicked;
  final String uom;
  final bool isConfirmed;
  final String? batchLotNumber;
  final DateTime? expiryDate;
  final int stepOrder; // Optimal walking path sequence (1, 2, 3...)

  const PickTask({
    required this.id,
    required this.orderId,
    required this.soNumber,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.location,
    required this.quantityToPick,
    this.quantityPicked = 0.0,
    required this.uom,
    this.isConfirmed = false,
    this.batchLotNumber,
    this.expiryDate,
    required this.stepOrder,
  });

  bool get isCompleted => isConfirmed && quantityPicked >= quantityToPick;

  PickTask copyWith({
    String? id,
    String? orderId,
    String? soNumber,
    String? productId,
    String? productName,
    String? sku,
    String? location,
    double? quantityToPick,
    double? quantityPicked,
    String? uom,
    bool? isConfirmed,
    String? batchLotNumber,
    DateTime? expiryDate,
    int? stepOrder,
  }) {
    return PickTask(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      soNumber: soNumber ?? this.soNumber,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      location: location ?? this.location,
      quantityToPick: quantityToPick ?? this.quantityToPick,
      quantityPicked: quantityPicked ?? this.quantityPicked,
      uom: uom ?? this.uom,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      batchLotNumber: batchLotNumber ?? this.batchLotNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      stepOrder: stepOrder ?? this.stepOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'soNumber': soNumber,
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'location': location,
        'quantityToPick': quantityToPick,
        'quantityPicked': quantityPicked,
        'uom': uom,
        'isConfirmed': isConfirmed,
        'batchLotNumber': batchLotNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'stepOrder': stepOrder,
      };

  factory PickTask.fromJson(Map<String, dynamic> json) => PickTask(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        soNumber: json['soNumber'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        sku: json['sku'] as String,
        location: json['location'] as String,
        quantityToPick: (json['quantityToPick'] as num).toDouble(),
        quantityPicked: (json['quantityPicked'] as num?)?.toDouble() ?? 0.0,
        uom: json['uom'] as String,
        isConfirmed: json['isConfirmed'] as bool? ?? false,
        batchLotNumber: json['batchLotNumber'] as String?,
        expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
        stepOrder: json['stepOrder'] as int? ?? 1,
      );
}

@immutable
class PickingWave {
  final String id;
  final String waveNumber;
  final String? assignedPickerId;
  final String? assignedPickerName;
  final List<String> orderIds;
  final WaveStatus status;
  final List<PickTask> tasks;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String zone;

  const PickingWave({
    required this.id,
    required this.waveNumber,
    this.assignedPickerId,
    this.assignedPickerName,
    required this.orderIds,
    this.status = WaveStatus.created,
    required this.tasks,
    required this.createdAt,
    this.completedAt,
    this.zone = 'Zone A (Main Warehouse)',
  });

  int get totalTasksCount => tasks.length;
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  double get progress => totalTasksCount == 0 ? 0.0 : (completedTasksCount / totalTasksCount);
  bool get isAllPicked => totalTasksCount > 0 && completedTasksCount == totalTasksCount;

  PickingWave copyWith({
    String? id,
    String? waveNumber,
    String? assignedPickerId,
    String? assignedPickerName,
    List<String>? orderIds,
    WaveStatus? status,
    List<PickTask>? tasks,
    DateTime? createdAt,
    DateTime? completedAt,
    String? zone,
  }) {
    return PickingWave(
      id: id ?? this.id,
      waveNumber: waveNumber ?? this.waveNumber,
      assignedPickerId: assignedPickerId ?? this.assignedPickerId,
      assignedPickerName: assignedPickerName ?? this.assignedPickerName,
      orderIds: orderIds ?? this.orderIds,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      zone: zone ?? this.zone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'waveNumber': waveNumber,
        'assignedPickerId': assignedPickerId,
        'assignedPickerName': assignedPickerName,
        'orderIds': orderIds,
        'status': status.name,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'zone': zone,
      };

  factory PickingWave.fromJson(Map<String, dynamic> json) => PickingWave(
        id: json['id'] as String,
        waveNumber: json['waveNumber'] as String,
        assignedPickerId: json['assignedPickerId'] as String?,
        assignedPickerName: json['assignedPickerName'] as String?,
        orderIds: List<String>.from(json['orderIds'] as List),
        status: WaveStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => WaveStatus.created,
        ),
        tasks: (json['tasks'] as List)
            .map((t) => PickTask.fromJson(Map<String, dynamic>.from(t as Map)))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        zone: json['zone'] as String? ?? 'Zone A (Main Warehouse)',
      );
}
