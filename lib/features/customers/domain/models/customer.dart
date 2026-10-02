import 'package:flutter/material.dart';

enum CustomerTier {
  enterprise,
  wholesale,
  retail,
  healthcarePriority,
}

extension CustomerTierExtension on CustomerTier {
  String get label {
    switch (this) {
      case CustomerTier.enterprise:
        return 'Enterprise Platinum';
      case CustomerTier.wholesale:
        return 'Wholesale Tier 1';
      case CustomerTier.retail:
        return 'Retail';
      case CustomerTier.healthcarePriority:
        return 'Healthcare Priority';
    }
  }

  Color get color {
    switch (this) {
      case CustomerTier.enterprise:
        return const Color(0xFF6366F1); // Indigo
      case CustomerTier.wholesale:
        return const Color(0xFF3B82F6); // Blue
      case CustomerTier.retail:
        return const Color(0xFF10B981); // Emerald
      case CustomerTier.healthcarePriority:
        return const Color(0xFFEC4899); // Pink
    }
  }
}

class Customer {
  final String id;
  final String code; // e.g. CUST-001
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String gstin;
  final String city;
  final String address;
  final CustomerTier tier;
  final bool isActive;
  final int totalOrders;
  final double outstandingBalance;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.code,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.gstin,
    required this.city,
    required this.address,
    this.tier = CustomerTier.enterprise,
    this.isActive = true,
    this.totalOrders = 0,
    this.outstandingBalance = 0.0,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? code,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? gstin,
    String? city,
    String? address,
    CustomerTier? tier,
    bool? isActive,
    int? totalOrders,
    double? outstandingBalance,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      city: city ?? this.city,
      address: address ?? this.address,
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      totalOrders: totalOrders ?? this.totalOrders,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
