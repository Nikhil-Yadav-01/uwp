import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../../rbac/presentation/controllers/user_role_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@warehouse-erp.com');
  final _passCtrl = TextEditingController(text: '••••••••••••');
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login([UserRole? role]) {
    if (role != null) {
      ref.read(userRoleProvider.notifier).switchRole(role);
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: AppPadding.p24,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: AppPadding.p32,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.r16),
                border: Border.all(color: colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & App Name
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: archetype.brandColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warehouse_rounded, size: 36, color: archetype.brandColor),
                    ),
                  ),
                  AppGap.h16,
                  Center(
                    child: Text(
                      'Universal WMS ERP',
                      style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  AppGap.h4,
                  Center(
                    child: Text(
                      'Secure multi-facility access portal',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  // Email Field
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email / Username',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                  AppGap.h12,

                  // Password Field
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  AppGap.h12,

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          ),
                          const Text('Remember me', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  AppGap.h16,

                  // Login Button
                  ElevatedButton(
                    onPressed: () => _login(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Sign In to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  AppGap.h24,

                  // Quick Demo Persona Access
                  Center(
                    child: Text(
                      '1-Click Demo Login as Persona',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ),
                  AppGap.h8,
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickRoleChip('Super Admin', UserRole.superAdmin),
                      _buildQuickRoleChip('WH Manager', UserRole.warehouseManager),
                      _buildQuickRoleChip('Floor Picker', UserRole.picker),
                      _buildQuickRoleChip('Auditor', UserRole.auditor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoleChip(String label, UserRole role) {
    return ActionChip(
      avatar: CircleAvatar(
        radius: 8,
        backgroundColor: role.badgeColor,
      ),
      label: Text(label, style: const TextStyle(fontSize: 10)),
      onPressed: () => _login(role),
    );
  }
}
