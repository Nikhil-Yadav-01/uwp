import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../rbac/presentation/controllers/user_role_controller.dart';
import '../../domain/models/admin_models.dart';

class AdminState {
  final List<SystemUser> users;
  final List<SystemAuditLogEntry> auditLogs;
  final int selectedTab; // 0 = Users & Roles, 1 = System Audit Log
  final String searchQuery;

  const AdminState({
    required this.users,
    required this.auditLogs,
    this.selectedTab = 0,
    this.searchQuery = '',
  });

  List<SystemUser> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    final q = searchQuery.toLowerCase();
    return users.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.role.displayName.toLowerCase().contains(q)).toList();
  }

  List<SystemAuditLogEntry> get filteredLogs {
    if (searchQuery.isEmpty) return auditLogs;
    final q = searchQuery.toLowerCase();
    return auditLogs.where((l) => l.userName.toLowerCase().contains(q) || l.action.toLowerCase().contains(q) || l.module.toLowerCase().contains(q) || l.details.toLowerCase().contains(q)).toList();
  }

  AdminState copyWith({
    List<SystemUser>? users,
    List<SystemAuditLogEntry>? auditLogs,
    int? selectedTab,
    String? searchQuery,
  }) {
    return AdminState(
      users: users ?? this.users,
      auditLogs: auditLogs ?? this.auditLogs,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier()
      : super(
          AdminState(
            users: [
              SystemUser(id: 'USR-01', name: 'Rahul Sharma', email: 'rahul@company.com', role: UserRole.superAdmin, lastActive: DateTime.now().subtract(const Duration(minutes: 5))),
              SystemUser(id: 'USR-02', name: 'Priya Singh', email: 'priya@company.com', role: UserRole.warehouseManager, lastActive: DateTime.now().subtract(const Duration(hours: 1))),
              SystemUser(id: 'USR-03', name: 'Amit Kumar', email: 'amit@company.com', role: UserRole.purchaseManager, lastActive: DateTime.now().subtract(const Duration(hours: 3))),
              SystemUser(id: 'USR-04', name: 'Neha Verma', email: 'neha@company.com', role: UserRole.picker, lastActive: DateTime.now().subtract(const Duration(minutes: 15))),
              SystemUser(id: 'USR-05', name: 'Sanjay Rao', email: 'sanjay@company.com', role: UserRole.packer, lastActive: DateTime.now().subtract(const Duration(minutes: 30))),
              SystemUser(id: 'USR-06', name: 'Deepak Patel', email: 'deepak@company.com', role: UserRole.auditor, lastActive: DateTime.now().subtract(const Duration(days: 1))),
            ],
            auditLogs: [
              SystemAuditLogEntry(
                id: 'LOG-01',
                timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
                userName: 'Rahul Sharma',
                userRole: 'Super Admin',
                action: 'Stock Adjustment',
                module: 'Inventory',
                details: 'Adjusted Qty -5 for SKU LAP-HP-15 in Bin A01-01-02 (Variance reconciliation)',
                referenceNumber: 'ADJ-0083',
              ),
              SystemAuditLogEntry(
                id: 'LOG-02',
                timestamp: DateTime.now().subtract(const Duration(hours: 1)),
                userName: 'Priya Singh',
                userRole: 'Warehouse Manager',
                action: 'Putaway Complete',
                module: 'Inbound',
                details: 'Confirmed putaway for GRN-0012 (148 units Samsung Galaxy A55 to Zone A)',
                referenceNumber: 'GRN-0012',
              ),
              SystemAuditLogEntry(
                id: 'LOG-03',
                timestamp: DateTime.now().subtract(const Duration(hours: 2)),
                userName: 'Neha Verma',
                userRole: 'Warehouse Picker',
                action: 'Wave Picking Dispatched',
                module: 'Outbound',
                details: 'Dispatched Wave PW-001 with 24 line items along shortest aisle route',
                referenceNumber: 'SO-0456',
              ),
              SystemAuditLogEntry(
                id: 'LOG-04',
                timestamp: DateTime.now().subtract(const Duration(hours: 4)),
                userName: 'Amit Kumar',
                userRole: 'Purchase Manager',
                action: 'New PO Approved',
                module: 'Inbound',
                details: 'Created and approved purchase order for ABC Traders & Global Imports',
                referenceNumber: 'PO-2026-0012',
              ),
              SystemAuditLogEntry(
                id: 'LOG-05',
                timestamp: DateTime.now().subtract(const Duration(hours: 6)),
                userName: 'Rahul Sharma',
                userRole: 'Super Admin',
                action: 'User Login',
                module: 'Auth',
                details: 'Successful biometric / session authentication from IP 192.168.1.42',
              ),
            ],
          ),
        );

  void setSelectedTab(int tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void addUser({
    required String name,
    required String email,
    required UserRole role,
  }) {
    final nextId = 'USR-${(state.users.length + 1).toString().padLeft(2, '0')}';
    final user = SystemUser(
      id: nextId,
      name: name,
      email: email,
      role: role,
      lastActive: DateTime.now(),
    );
    state = state.copyWith(users: [user, ...state.users]);
  }

  void toggleUserStatus(String id) {
    final updated = state.users.map((u) {
      if (u.id == id) return u.copyWith(isActive: !u.isActive);
      return u;
    }).toList();
    state = state.copyWith(users: updated);
  }
}

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});
