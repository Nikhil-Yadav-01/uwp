import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Electronics & Tech products
class ElectronicsProductWrapper {
  final Product product;

  const ElectronicsProductWrapper(this.product);

  String? get serialNumber =>
      product.customAttributes['serial_no'] as String?;

  String? get primaryImei => product.customAttributes['imei_1'] as String?;

  String? get secondaryImei => product.customAttributes['imei_2'] as String?;

  String? get conditionState =>
      product.customAttributes['condition'] as String?;

  String? get warrantyMonths =>
      product.customAttributes['warranty_months'] as String?;

  bool get isRMA => conditionState?.toUpperCase().contains('RMA') ?? false;

  bool get isRefurbished =>
      conditionState?.toLowerCase().contains('refurbished') ?? false;
}
