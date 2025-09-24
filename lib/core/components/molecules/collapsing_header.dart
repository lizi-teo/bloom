import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';
import '../../themes/spacing_theme.dart';
import '../../services/image_cache_service.dart';

/// Material Design 3 compliant responsive header component
/// Follows theme-based spacing and proper responsive patterns
/// Uses standardized padding and heights for consistent UX
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
    final theme = Theme.of(context);
    final screenSize = getScreenSize(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainer,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: _getVerticalPadding(screenSize, context),
          ),
          child: _buildResponsiveContent(screenSize, theme, context),
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(ScreenSize screenSize, ThemeData theme, BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getMaxContentWidth(screenSize),
        ),
        child: Padding(
          padding: _getContentPadding(screenSize, context),
          child: _buildHeaderContent(screenSize, theme, context),
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
              style: _getResponsiveTextStyle(screenSize, theme),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: context.spacing.xl),
          _buildHeaderIcon(screenSize, context),
        ],
      );
    } else {
      // Compact/Medium layout: centered icon and text
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderIcon(screenSize, context),
          SizedBox(height: context.spacing.lg),
          Text(
            title,
            style: _getResponsiveTextStyle(screenSize, theme),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
  }

  Widget _buildHeaderIcon(ScreenSize screenSize, BuildContext context) {
    final iconSize = _getResponsiveIconSize(screenSize, context);

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? const Color(0xFFF8E503),
        shape: BoxShape.circle,
      ),
      child: imageUrl != null
          ? ClipOval(
              child: _HeaderIconImage(
                imageUrl: imageUrl!,
                iconSize: iconSize,
              ),
            )
          : _buildFallbackIcon(iconSize, context),
    );
  }

  Widget _buildFallbackIcon(double iconSize, BuildContext context) {
    return Icon(
      Icons.favorite,
      size: iconSize * 0.4,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  // Vertical padding only - no horizontal padding on container
  double _getVerticalPadding(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:
        return context.spacing.lg; // 16dp
      case ScreenSize.medium:
        return context.spacing.xl; // 24dp
      case ScreenSize.expanded:
        return context.spacing.xl; // 24dp
    }
  }

  // Content padding within the responsive constraint
  EdgeInsets _getContentPadding(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.symmetric(horizontal: context.spacing.lg); // 16dp
      case ScreenSize.medium:
        return EdgeInsets.symmetric(horizontal: context.spacing.xl); // 24dp
      case ScreenSize.expanded:
        return EdgeInsets.symmetric(horizontal: context.spacing.xxl); // 32dp
    }
  }

  // Max content width for different screen sizes
  double _getMaxContentWidth(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return double.infinity; // Full width on mobile
      case ScreenSize.medium:
        return 800.0; // Constrained width on tablet
      case ScreenSize.expanded:
        return 1200.0; // Max width on desktop
    }
  }

  // Material Design 3 responsive icon sizes
  double _getResponsiveIconSize(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 80.0; // Reduced from 100dp for better mobile fit
      case ScreenSize.medium:
        return 96.0; // Medium tablet size
      case ScreenSize.expanded:
        return 112.0; // Reduced from 128dp for better proportion
    }
  }

  // Material Design 3 responsive typography
  TextStyle _getResponsiveTextStyle(ScreenSize screenSize, ThemeData theme) {
    switch (screenSize) {
      case ScreenSize.compact:
        return theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ?? const TextStyle();
      case ScreenSize.medium:
        return theme.textTheme.headlineLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ?? const TextStyle();
      case ScreenSize.expanded:
        return theme.textTheme.displaySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ?? const TextStyle();
    }
  }
}

/// Custom image widget that checks cache immediately to prevent flash
class _HeaderIconImage extends StatelessWidget {
  final String imageUrl;
  final double iconSize;

  const _HeaderIconImage({
    required this.imageUrl,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CachedImage?>(
      future: ImageCacheService().getImage(
        imageUrl,
        targetSize: Size(iconSize, iconSize),
        fit: BoxFit.contain,
      ),
      builder: (context, snapshot) {
        // If we have data (cached or newly loaded), show image immediately
        if (snapshot.hasData && snapshot.data != null) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Image(
              image: snapshot.data!.imageProvider,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              key: ValueKey(snapshot.data!.url),
            ),
          );
        }

        // If there's an error, show fallback
        if (snapshot.hasError || (snapshot.connectionState == ConnectionState.done && snapshot.data == null)) {
          return Icon(
            Icons.favorite,
            size: iconSize * 0.4,
            color: Theme.of(context).colorScheme.primary,
          );
        }

        // Only show loading indicator if actually waiting for network
        // For cached images, this should be skipped
        return Center(
          child: SizedBox(
            width: iconSize * 0.3,
            height: iconSize * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
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