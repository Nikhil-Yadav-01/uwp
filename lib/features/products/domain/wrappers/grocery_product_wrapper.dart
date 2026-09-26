import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Grocery, Cold-Chain & Perishable items
class GroceryProductWrapper {
  final Product product;

  const GroceryProductWrapper(this.product);

  String? get batchNumber => product.customAttributes['batch_no'] as String?;

  String? get expiryDateString =>
      product.customAttributes['expiry_date'] as String?;

  DateTime? get expiryDate {
    final str = expiryDateString;
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  String? get storageZone =>
      product.customAttributes['storage_zone'] as String?;

  String? get farmOrigin => product.customAttributes['origin'] as String?;

  int? get daysUntilExpiry {
    final exp = expiryDate;
    if (exp == null) return null;
    final now = DateTime.now();
    return exp.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  bool get isExpired {
    final days = daysUntilExpiry;
    if (days == null) return false;
    return days < 0;
  }

  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    if (days == null) return false;
    return days >= 0 && days <= 3;
  }

  String get coldChainZone => storageZone ?? 'Ambient (+20°C)';
}
