enum PaymentTerms {
  advance,
  net15,
  net30,
  net60,
}

extension PaymentTermsExtension on PaymentTerms {
  String get label {
    switch (this) {
      case PaymentTerms.advance:
        return '100% Advance';
      case PaymentTerms.net15:
        return 'Net 15 Days';
      case PaymentTerms.net30:
        return 'Net 30 Days';
      case PaymentTerms.net60:
        return 'Net 60 Days';
    }
  }
}

class Vendor {
  final String id;
  final String code; // e.g. SUP-001
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String gstin;
  final String city;
  final String address;
  final double rating; // 1.0 - 5.0
  final PaymentTerms paymentTerms;
  final int leadTimeDays;
  final bool isActive;
  final int totalPurchaseOrders;
  final DateTime createdAt;

  const Vendor({
    required this.id,
    required this.code,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.gstin,
    required this.city,
    required this.address,
    this.rating = 4.8,
    this.paymentTerms = PaymentTerms.net30,
    this.leadTimeDays = 3,
    this.isActive = true,
    this.totalPurchaseOrders = 0,
    required this.createdAt,
  });

  Vendor copyWith({
    String? id,
    String? code,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? gstin,
    String? city,
    String? address,
    double? rating,
    PaymentTerms? paymentTerms,
    int? leadTimeDays,
    bool? isActive,
    int? totalPurchaseOrders,
    DateTime? createdAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      city: city ?? this.city,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      isActive: isActive ?? this.isActive,
      totalPurchaseOrders: totalPurchaseOrders ?? this.totalPurchaseOrders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
