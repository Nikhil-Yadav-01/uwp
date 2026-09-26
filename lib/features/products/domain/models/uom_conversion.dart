/// Custom or standard UOM conversion ratio (e.g. 1 Box = 10 Pcs).
class UomConversionRatio {
  final String fromUom;
  final String toUom;
  final double multiplier; // To convert fromUom -> toUom, multiply by multiplier

  const UomConversionRatio({
    required this.fromUom,
    required this.toUom,
    required this.multiplier,
  });

  Map<String, dynamic> toJson() => {
        'fromUom': fromUom,
        'toUom': toUom,
        'multiplier': multiplier,
      };

  factory UomConversionRatio.fromJson(Map<String, dynamic> json) =>
      UomConversionRatio(
        fromUom: json['fromUom'] as String,
        toUom: json['toUom'] as String,
        multiplier: (json['multiplier'] as num).toDouble(),
      );

  @override
  String toString() => '1 $fromUom = $multiplier $toUom';
}
