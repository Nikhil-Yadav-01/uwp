import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Hardware, Industrial Parts & HAZMAT
class HardwareProductWrapper {
  final Product product;

  const HardwareProductWrapper(this.product);

  String? get oemPartNumber =>
      product.customAttributes['oem_part_number'] as String?;

  String? get binLocation =>
      product.customAttributes['bin_location'] as String?;

  String? get vehicleFitment =>
      product.customAttributes['vehicle_fitment'] as String?;

  bool get isHazardous =>
      product.customAttributes['is_hazardous'] as bool? ?? false;

  String get routingLocation => binLocation ?? 'Unassigned Bay';
}
