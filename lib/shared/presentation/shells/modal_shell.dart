import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/responsive/responsive.dart';

class ModalShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const ModalShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  /// Shows adaptive modal as bottom sheet on compact screens and dialog on medium/large screens
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
  }) {
    if (Responsive.isCompact(context)) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ModalShell(title: title, actions: actions, child: child),
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.xLarge),
          child: SizedBox(
            width: AppSizes.maxModalWidth,
            child: ModalShell(title: title, actions: actions, child: child),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppPadding.screenHorizontalValue(context);

    return Container(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, padding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: AppRadii.rad24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle for mobile bottom sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: AppRadii.small,
              ),
            ),
          ),
          AppGap.h16,

          // Title & Close Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.headlineSmall),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          AppGap.h16,

          // Content
          Flexible(child: SingleChildScrollView(child: child)),

          // Actions
          if (actions != null) ...[
            AppGap.h24,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
