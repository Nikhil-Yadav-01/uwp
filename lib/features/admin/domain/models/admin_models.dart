import '../../../rbac/presentation/controllers/user_role_controller.dart';

class SystemUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final String assignedWarehouse;
  final DateTime lastActive;

  const SystemUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.assignedWarehouse = 'WH01 (Delhi)',
    required this.lastActive,
  });

  SystemUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    String? assignedWarehouse,
    DateTime? lastActive,
  }) {
    return SystemUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      assignedWarehouse: assignedWarehouse ?? this.assignedWarehouse,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class SystemAuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String userName;
  final String userRole;
  final String action; // e.g. Stock Adjustment, Putaway, User Login
  final String module; // e.g. Inbound, Outbound, Inventory, Auth
  final String details;
  final String? referenceNumber;

  const SystemAuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.module,
    required this.details,
    this.referenceNumber,
  });
}
