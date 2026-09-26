import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Healthcare, Pharma & Hospital Supplies
class HealthcareProductWrapper {
  final Product product;

  const HealthcareProductWrapper(this.product);

  String? get pharmaLotNo => product.customAttributes['lot_no'] as String?;

  String? get medicalExpiryDateString =>
      product.customAttributes['expiry_date'] as String?;

  DateTime? get medicalExpiryDate {
    final str = medicalExpiryDateString;
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  String? get drugSchedule =>
      product.customAttributes['schedule_class'] as String?;

  String? get allocatedWard =>
      product.customAttributes['allocated_ward'] as String?;

  bool get isControlledNarcotic =>
      (drugSchedule?.toLowerCase().contains('controlled') ?? false) ||
      (drugSchedule?.toLowerCase().contains('schedule ii') ?? false);

  bool get requiresDualSignature => isControlledNarcotic;
}
