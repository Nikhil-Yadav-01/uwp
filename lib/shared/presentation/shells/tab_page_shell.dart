import 'package:flutter/material.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/responsive/responsive.dart';

class TabPageShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? brandWidget;
  final bool hasOwnScroll;
  final Gradient headerGradient;

  const TabPageShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.brandWidget,
    this.hasOwnScroll = false,
    this.headerGradient = AppGradients.header,
  });

  @override
  Widget build(BuildContext context) {
    final headerHeight = AppSizes.headerHeight(context);
    final screenPadding = AppPadding.screenHorizontalValue(context);

    final contentWidget = hasOwnScroll
        ? body
        : SingleChildScrollView(
            padding: EdgeInsets.all(screenPadding),
            child: body,
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Header Gradient Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 20,
            child: Container(
              decoration: BoxDecoration(gradient: headerGradient),
            ),
          ),

          // 2. Main Tab Body Container with Constrained Ultra-Wide Width
          Column(
            children: [
              SizedBox(height: headerHeight),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: AppRadii.rad24,
                      topRight: AppRadii.rad24,
                    ),
                  ),
                  child: Responsive.constrainedContent(child: contentWidget),
                ),
              ),
            ],
          ),

          // 3. Tab Bar Top Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Responsive.constrainedContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenPadding),
                child: Row(
                  children: [
                    brandWidget ??
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.apps_rounded, color: Colors.white),
                        ),
                    AppGap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            Text(
                              subtitle!,
                              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    ...?actions,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
