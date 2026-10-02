import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../../rbac/presentation/controllers/user_role_controller.dart';
import '../../domain/models/admin_models.dart';
import '../controllers/admin_controller.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final adminNotifier = ref.read(adminNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;

                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Text('Administration & Audit Governance', style: AppTypography.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              'Enterprise Security',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: archetype.brandColor),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Manage system users, assign role-based permissions, and inspect immutable audit trail logs',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final actionBtn = adminState.selectedTab == 0
                      ? ElevatedButton.icon(
                          onPressed: () => _showAddUserModal(context),
                          icon: const Icon(Icons.person_add_rounded, size: AppSizes.iconSm),
                          label: const Text('Add User'),
                        )
                      : OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Exported Complete System Audit Trail (CSV / Security Log)'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: AppSizes.iconSm),
                          label: const Text('Export Audit Log'),
                        );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: actionBtn),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      actionBtn,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. Navigation Tabs (Users vs Audit Log)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: const Text('Users & Role Management'),
                    selected: adminState.selectedTab == 0,
                    avatar: const Icon(Icons.people_alt_outlined, size: 16),
                    onSelected: (_) => adminNotifier.setSelectedTab(0),
                  ),
                  ChoiceChip(
                    label: const Text('System Audit Log'),
                    selected: adminState.selectedTab == 1,
                    avatar: const Icon(Icons.security_rounded, size: 16),
                    onSelected: (_) => adminNotifier.setSelectedTab(1),
                  ),
                ],
              ),
              AppGap.h16,

              // 3. Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: adminState.selectedTab == 0
                        ? 'Search users by name, email, or role...'
                        : 'Search audit logs by user, action, module, or details...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: adminNotifier.setSearchQuery,
                ),
              ),
              AppGap.h20,

              // 4. Tab Content (Users Table vs Audit Log Table)
              if (adminState.selectedTab == 0)
                _buildUsersTableView(adminState.filteredUsers, adminNotifier, archetype.brandColor, isDark, colorScheme)
              else
                _buildAuditLogTableView(adminState.filteredLogs, archetype.brandColor, isDark, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTableView(
    List<SystemUser> users,
    AdminNotifier notifier,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text('System Users & Permissions', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: brandColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: Text('${users.length} Active Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: brandColor)),
              ),
            ],
          ),
          AppGap.h16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return _buildMobileUsersList(users, notifier, isDark, colorScheme);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Staff Member')),
                    DataColumn(label: Text('Email Address')),
                    DataColumn(label: Text('Assigned Role')),
                    DataColumn(label: Text('Assigned Facility')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: users.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: user.role.badgeColor,
                                child: Text(user.role.shortCode, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              AppGap.w8,
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        DataCell(Text(user.email)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.role.badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.displayName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: user.role.badgeColor),
                            ),
                          ),
                        ),
                        DataCell(Text(user.assignedWarehouse)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (user.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.isActive ? 'Active' : 'Disabled',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: user.isActive ? AppColors.success : AppColors.error),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(user.isActive ? Icons.block_rounded : Icons.check_circle_outline, size: 18),
                            tooltip: user.isActive ? 'Disable User' : 'Enable User',
                            onPressed: () => notifier.toggleUserStatus(user.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUsersList(
    List<SystemUser> users,
    AdminNotifier notifier,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No users found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => AppGap.h12,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: user.role.badgeColor,
                    child: Text(user.role.shortCode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  AppGap.w10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(user.isActive ? Icons.block_rounded : Icons.check_circle_outline, size: 20),
                    tooltip: user.isActive ? 'Disable User' : 'Enable User',
                    onPressed: () => notifier.toggleUserStatus(user.id),
                  ),
                ],
              ),
              AppGap.h8,
              const Divider(height: 1),
              AppGap.h8,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: user.role.badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: user.role.badgeColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (user.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.isActive ? 'Active' : 'Disabled',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: user.isActive ? AppColors.success : AppColors.error),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warehouse_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      AppGap.w4,
                      Text(
                        user.assignedWarehouse,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditLogTableView(
    List<SystemAuditLogEntry> logs,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text('Security & Audit Log Trail', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: const Text('Tamper-Evident Ledger', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.info)),
              ),
            ],
          ),
          AppGap.h16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return _buildMobileAuditLogsList(logs, brandColor, isDark, colorScheme);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Timestamp')),
                    DataColumn(label: Text('User / Persona')),
                    DataColumn(label: Text('Action Type')),
                    DataColumn(label: Text('Module')),
                    DataColumn(label: Text('Details / Payload')),
                  ],
                  rows: logs.map((log) {
                    return DataRow(
                      cells: [
                        DataCell(Text('${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')} (Today)', style: const TextStyle(fontSize: 11))),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(log.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(log.userRole, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: brandColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                            child: Text(log.action, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: brandColor)),
                          ),
                        ),
                        DataCell(Text(log.module, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Text(log.details, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAuditLogsList(
    List<SystemAuditLogEntry> logs,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No audit logs found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (_, __) => AppGap.h12,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          log.userRole,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')} (Today)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              AppGap.h8,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: brandColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text(log.action, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: brandColor)),
                  ),
                  Text(
                    log.module,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
              AppGap.h6,
              Text(
                log.details,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddUserModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    var selectedRole = UserRole.picker;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => AlertDialog(
          title: const Text('Add System Staff User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Staff Name')),
              AppGap.h8,
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Company Email')),
              AppGap.h12,
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Assigned Role'),
                items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.displayName))).toList(),
                onChanged: (val) {
                  if (val != null) setStateModal(() => selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  ref.read(adminNotifierProvider.notifier).addUser(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        role: selectedRole,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
