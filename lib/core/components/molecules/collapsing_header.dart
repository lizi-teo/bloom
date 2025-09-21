import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';
import '../../themes/spacing_theme.dart';

/// A collapsing header component that uses SliverAppBar for scroll-based animations
/// Based on Material Design 3 with responsive breakpoints
/// Implements fade and scale animations as recommended by Material Design 3
class CollapsingHeader extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;
  final double stretchTriggerOffset;
  final bool stretch;

  const CollapsingHeader({
    super.key,
    required this.title,
    this.imageUrl,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.stretchTriggerOffset = 100.0,
    this.stretch = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    final calculatedHeight = expandedHeight ?? _getHeaderHeight(screenSize, context);

    return SliverAppBar(
      expandedHeight: calculatedHeight,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
      pinned: pinned,
      floating: floating,
      snap: snap,
      stretch: stretch,
      stretchTriggerOffset: stretchTriggerOffset,
      automaticallyImplyLeading: false, // Remove back button
      surfaceTintColor: Colors.transparent, // Remove Material 3 tint
      scrolledUnderElevation: 0, // No elevation as requested
      toolbarHeight: 0, // Hide collapsed toolbar to prevent height conflicts
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Simplified animation progress (0.0 = collapsed, 1.0 = expanded)
          final double expandRatio = constraints.maxHeight > 0
              ? (constraints.maxHeight / calculatedHeight).clamp(0.0, 1.0)
              : 0.0;

          // Simple fade animation without curves to improve performance
          final double fadeOpacity = expandRatio;

          return FlexibleSpaceBar(
            centerTitle: false,
            expandedTitleScale: 1.0,
            collapseMode: CollapseMode.parallax,
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
            ],
            background: Opacity(
              opacity: fadeOpacity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getHeaderHorizontalPadding(screenSize, context),
                  vertical: _getHeaderVerticalPadding(screenSize, context),
                ),
                child: _buildHeaderContent(screenSize, Theme.of(context), context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(ScreenSize screenSize, ThemeData theme, BuildContext context) {
    if (screenSize == ScreenSize.expanded) {
      // Expanded layout: text on left, icon on right
      return Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: _getDisplayStyle(screenSize, theme).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: context.spacing.xxl),
          _buildHeaderIcon(screenSize),
        ],
      );
    } else {
      // Compact/Medium layout: centered icon and text
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderIcon(screenSize),
          SizedBox(height: _getIconTextSpacing(screenSize, context)),
          Flexible(
            child: Text(
              title,
              style: _getDisplayStyle(screenSize, theme).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildHeaderIcon(ScreenSize screenSize) {
    final iconSize = _getHeaderIconSize(screenSize);

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? const Color(0xFFF8E503), // Yellow from Figma
        borderRadius: BorderRadius.circular(iconSize / 2), // Circular using Flutter theme approach
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(iconSize / 2), // Circular clip
              child: Image.network(
                imageUrl!,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: iconSize * 0.4,
                      height: iconSize * 0.4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: const Color(0xFF9E8AEF), // Pink heart color to match fallback
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(screenSize),
              ),
            )
          : _buildFallbackIcon(screenSize),
    );
  }

  Widget _buildFallbackIcon(ScreenSize screenSize) {
    final iconSize = _getHeaderIconSize(screenSize);
    return Icon(
      Icons.favorite,
      size: iconSize * 0.4, // 40% of container size as per Figma
      color: const Color(0xFF9E8AEF), // Pink heart color
    );
  }

  // Responsive sizing helper methods with proper height calculation
  double _getHeaderHeight(ScreenSize screenSize, BuildContext context) {
    final iconSize = _getHeaderIconSize(screenSize);
    final verticalPadding = _getHeaderVerticalPadding(screenSize, context);
    final iconTextSpacing = screenSize != ScreenSize.expanded ? _getIconTextSpacing(screenSize, context) : 0;
    final textHeight = screenSize != ScreenSize.expanded ? context.spacing.xxxl : context.spacing.xxl; // Theme-based text height

    return verticalPadding + iconSize + iconTextSpacing + textHeight + context.spacing.sm; // Theme-based bottom spacing
  }

  // Responsive padding using ScreenSize enum pattern (organisms guide)
  double _getHeaderHorizontalPadding(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:   // < 600dp
        return context.spacing.lg; // Mobile-first: standard content padding
      case ScreenSize.medium:    // 600-959dp
        return context.spacing.xl; // Tablet: section separation
      case ScreenSize.expanded:  // >= 960dp
        return context.spacing.xl; // Desktop: section separation
    }
  }

  double _getHeaderVerticalPadding(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:   // < 600dp
        return context.spacing.lg; // Mobile-first: standard content padding
      case ScreenSize.medium:    // 600-959dp
        return context.spacing.xl; // Tablet: section separation
      case ScreenSize.expanded:  // >= 960dp
        return context.spacing.xl; // Desktop: section separation
    }
  }

  double _getHeaderIconSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
      case ScreenSize.medium:
        return 100.0; // 100dp compact/medium (from Figma)
      case ScreenSize.expanded:
        return 128.0; // 128dp expanded
    }
  }

  double _getIconTextSpacing(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:   // < 600dp
        return context.spacing.md; // Mobile: small component gaps
      case ScreenSize.medium:    // 600-959dp
        return context.spacing.lg; // Tablet: standard content padding
      case ScreenSize.expanded:  // >= 960dp
        return context.spacing.xl; // Desktop: section separation
    }
  }

  // Responsive typography using Flutter theme
  TextStyle _getDisplayStyle(ScreenSize screenSize, ThemeData theme) {
    switch (screenSize) {
      case ScreenSize.compact:
        return theme.textTheme.headlineLarge!; // Headline large for mobile
      case ScreenSize.medium:
        return theme.textTheme.headlineLarge!; // Headline large for tablet
      case ScreenSize.expanded:
        return theme.textTheme.displayMedium!; // Display medium for desktop
    }
  }
}