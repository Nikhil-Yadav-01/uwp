import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported Enterprise User Roles
enum UserRole {
  superAdmin,
  warehouseManager,
  purchaseManager,
  picker,
  packer,
  auditor,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.warehouseManager:
        return 'Warehouse Manager';
      case UserRole.purchaseManager:
        return 'Purchase Manager';
      case UserRole.picker:
        return 'Warehouse Picker';
      case UserRole.packer:
        return 'Packing & Dispatch';
      case UserRole.auditor:
        return 'Inventory Auditor';
    }
  }

  String get shortCode {
    switch (this) {
      case UserRole.superAdmin:
        return 'SA';
      case UserRole.warehouseManager:
        return 'WM';
      case UserRole.purchaseManager:
        return 'PM';
      case UserRole.picker:
        return 'PK';
      case UserRole.packer:
        return 'PD';
      case UserRole.auditor:
        return 'AU';
    }
  }

  String get permissionBadge {
    switch (this) {
      case UserRole.superAdmin:
        return 'All Permissions';
      case UserRole.warehouseManager:
        return 'Ops & Stock Admin';
      case UserRole.purchaseManager:
        return 'PO & Intake Lead';
      case UserRole.picker:
        return 'Wave Picking & Scans';
      case UserRole.packer:
        return 'Station & Manifest';
      case UserRole.auditor:
        return 'Stock Audit & Logs';
    }
  }

  Color get badgeColor {
    switch (this) {
      case UserRole.superAdmin:
        return const Color(0xFF10B981);
      case UserRole.warehouseManager:
        return const Color(0xFF3B82F6);
      case UserRole.purchaseManager:
        return const Color(0xFFF59E0B);
      case UserRole.picker:
        return const Color(0xFF8B5CF6);
      case UserRole.packer:
        return const Color(0xFF06B6D4);
      case UserRole.auditor:
        return const Color(0xFFEC4899);
    }
  }

  bool canEditCatalog() => this == UserRole.superAdmin || this == UserRole.warehouseManager || this == UserRole.purchaseManager;
  bool canApproveTransfers() => this == UserRole.superAdmin || this == UserRole.warehouseManager;
  bool canPerformStockAdjustments() => this == UserRole.superAdmin || this == UserRole.warehouseManager || this == UserRole.auditor;
}

class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.superAdmin);

  void switchRole(UserRole newRole) {
    state = newRole;
  }
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>((ref) {
  return UserRoleNotifier();
});
