import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';
import '../../themes/spacing_theme.dart';

/// A simple fixed header component for mobile-first responsive design
/// Replaces complex SliverAppBar with sustainable implementation
/// Uses fixed heights for consistent mobile browser behavior
class CollapsingHeader extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;

  const CollapsingHeader({
    super.key,
    required this.title,
    this.imageUrl,
    this.backgroundColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    final headerHeight = _getHeaderHeight(screenSize, context);

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _getHeaderHorizontalPadding(screenSize, context),
            vertical: _getHeaderVerticalPadding(screenSize, context),
          ),
          child: _buildHeaderContent(screenSize, Theme.of(context), context),
        ),
      ),
    );
  }

  Widget _buildHeaderContent(ScreenSize screenSize, ThemeData theme, BuildContext context) {
    if (screenSize == ScreenSize.expanded) {
      // Expanded layout: text on left, icon on right
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: _getDisplayStyle(screenSize, theme).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: _getResponsiveLineHeight(screenSize), // Responsive line height
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeaderIcon(screenSize),
          SizedBox(height: _getIconTextSpacing(screenSize, context)),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: _getDisplayStyle(screenSize, theme).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: _getResponsiveLineHeight(screenSize), // Responsive line height
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
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
                // Android mobile connection timeout - 10 seconds
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
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image loading failed for $imageUrl: $error');
                  return _buildFallbackIcon(screenSize);
                },
                // Set explicit timeout for slow Android connections
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
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

  // Responsive header heights for cross-browser compatibility
  double _getHeaderHeight(ScreenSize screenSize, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = _getHeaderIconSize(screenSize);
    final verticalPadding = _getHeaderVerticalPadding(screenSize, context) * 2;
    final iconTextSpacing = screenSize != ScreenSize.expanded ? _getIconTextSpacing(screenSize, context) : 0;

    // Responsive text height calculation for Firefox compatibility
    final textStyle = _getDisplayStyle(screenSize, Theme.of(context));
    final baseFontSize = textStyle.fontSize ?? 24.0;

    // Screen-size specific height multipliers for better Firefox text rendering
    double textHeightMultiplier;
    switch (screenSize) {
      case ScreenSize.compact:
        textHeightMultiplier = 3.2; // More space for mobile Firefox
        break;
      case ScreenSize.medium:
        textHeightMultiplier = 3.0; // Tablet spacing
        break;
      case ScreenSize.expanded:
        textHeightMultiplier = 2.8; // Desktop can be more compact
        break;
    }

    final estimatedTextHeight = baseFontSize * 1.5 * textHeightMultiplier;
    final baseHeight = iconSize + iconTextSpacing + estimatedTextHeight + verticalPadding;

    // Responsive max height constraints
    final maxHeightPercent = screenSize == ScreenSize.compact ? 0.35 : 0.30;
    final maxHeight = screenHeight * maxHeightPercent;

    // Responsive minimum heights
    final minHeight = screenSize == ScreenSize.compact ? 180.0 : 160.0;

    return baseHeight.clamp(minHeight, maxHeight);
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

  // Responsive line height for cross-browser compatibility
  double _getResponsiveLineHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 1.5; // More generous line height for mobile Firefox
      case ScreenSize.medium:
        return 1.4; // Tablet spacing
      case ScreenSize.expanded:
        return 1.3; // Desktop can be more compact
    }
  }
}

/// Sliver wrapper for CollapsingHeader to maintain compatibility with CustomScrollView
class SliverCollapsingHeader extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;

  const SliverCollapsingHeader({
    super.key,
    required this.title,
    this.imageUrl,
    this.backgroundColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CollapsingHeader(
        title: title,
        imageUrl: imageUrl,
        backgroundColor: backgroundColor,
        iconBackgroundColor: iconBackgroundColor,
      ),
    );
  }
}