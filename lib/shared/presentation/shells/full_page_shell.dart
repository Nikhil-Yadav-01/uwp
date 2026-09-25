import 'package:flutter/material.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/responsive/responsive.dart';

class FullPageShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? overlay;
  final bool showBackButton;
  final bool hasOwnScroll;
  final Gradient headerGradient;

  const FullPageShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.leading,
    this.overlay,
    this.showBackButton = true,
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
          // 1. Header Gradient Background Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 20,
            child: Container(
              decoration: BoxDecoration(gradient: headerGradient),
            ),
          ),

          // 2. Main Content Body with Constrained Ultra-Wide Width
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

          // 3. Header Top Content Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Responsive.constrainedContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenPadding),
                child: Row(
                  children: [
                    _buildLeading(context),
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

          // 4. Optional Top Overlay Layer
          ?overlay,
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;
    if (!showBackButton) return const SizedBox();

    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
