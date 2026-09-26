import 'package:flutter/foundation.dart';

enum WeightUnit {
  kg,
  g,
  lb,
  oz,
}

@immutable
class WeightReading {
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final WeightUnit unit;
  final bool isStable;
  final DateTime? timestamp;

  const WeightReading({
    required this.grossWeight,
    this.tareWeight = 0.0,
    required this.netWeight,
    this.unit = WeightUnit.kg,
    this.isStable = true,
    this.timestamp,
  });

  WeightReading copyWith({
    double? grossWeight,
    double? tareWeight,
    double? netWeight,
    WeightUnit? unit,
    bool? isStable,
    DateTime? timestamp,
  }) {
    return WeightReading(
      grossWeight: grossWeight ?? this.grossWeight,
      tareWeight: tareWeight ?? this.tareWeight,
      netWeight: netWeight ?? this.netWeight,
      unit: unit ?? this.unit,
      isStable: isStable ?? this.isStable,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'grossWeight': grossWeight,
        'tareWeight': tareWeight,
        'netWeight': netWeight,
        'unit': unit.name,
        'isStable': isStable,
        'timestamp': timestamp?.toIso8601String(),
      };

  factory WeightReading.fromJson(Map<String, dynamic> json) => WeightReading(
        grossWeight: (json['grossWeight'] as num).toDouble(),
        tareWeight: (json['tareWeight'] as num?)?.toDouble() ?? 0.0,
        netWeight: (json['netWeight'] as num).toDouble(),
        unit: WeightUnit.values.firstWhere(
          (e) => e.name == json['unit'],
          orElse: () => WeightUnit.kg,
        ),
        isStable: json['isStable'] as bool? ?? true,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : null,
      );
}
