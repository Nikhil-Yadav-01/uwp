import 'package:flutter/material.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';

/// Universal Adaptive Modal Shell supporting Bottom Sheets on Mobile & Centered Dialogs on Desktop/Tablet.
class ModalShell extends StatelessWidget {
  final String? title;
  final Widget? headerWidget;
  final Widget? leading;
  final Widget child;
  final List<Widget>? actions;
  final double? maxWidth;
  final double maxHeightFraction;
  final bool isDialog;

  const ModalShell({
    super.key,
    this.title,
    this.headerWidget,
    this.leading,
    required this.child,
    this.actions,
    this.maxWidth,
    this.maxHeightFraction = 0.85,
    this.isDialog = false,
  });

  /// Shows adaptive modal as bottom sheet on compact screens and dialog on medium/large screens
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? headerWidget,
    Widget? leading,
    required Widget child,
    List<Widget>? actions,
    double? maxWidth,
    double maxHeightFraction = 0.85,
  }) {
    final isCompact = Responsive.isCompact(context);

    if (isCompact) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ModalShell(
          title: title,
          headerWidget: headerWidget,
          leading: leading,
          actions: actions,
          maxHeightFraction: maxHeightFraction,
          isDialog: false,
          child: child,
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r16)),
          child: ModalShell(
            title: title,
            headerWidget: headerWidget,
            leading: leading,
            actions: actions,
            maxWidth: maxWidth ?? AppSizes.maxModalWidth,
            maxHeightFraction: maxHeightFraction,
            isDialog: true,
            child: child,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxAllowedHeight = screenHeight * maxHeightFraction;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxAllowedHeight,
        maxWidth: isDialog ? (maxWidth ?? AppSizes.maxModalWidth) : double.infinity,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: isDialog
            ? BorderRadius.circular(AppRadii.r16)
            : const BorderRadius.vertical(top: Radius.circular(AppRadii.r24)),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle for mobile bottom sheet
          if (!isDialog)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
              child: Center(
                child: Container(
                  width: AppSizes.buttonHeightSm,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                  ),
                ),
              ),
            ),

          // Header Zone
          if (headerWidget != null)
            headerWidget!
          else if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    AppGap.w12,
                  ],
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: child,
            ),
          ),

          // Action Footer
          if (actions != null && actions!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: isDialog
                    ? const BorderRadius.vertical(bottom: Radius.circular(AppRadii.r16))
                    : BorderRadius.zero,
                border: Border(top: BorderSide(color: colorScheme.outline)),
              ),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
