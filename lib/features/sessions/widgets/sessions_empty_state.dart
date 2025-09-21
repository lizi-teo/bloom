import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/themes/spacing_theme.dart';

class SessionsEmptyState extends StatelessWidget {
  const SessionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        return _buildEmptyStateLayout(context, isCompact);
      },
    );
  }

  Widget _buildEmptyStateLayout(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0, // MD3 prefers minimal elevation
      shadowColor: Colors.transparent,
      surfaceTintColor: colorScheme.surface,
      color: colorScheme.surface, // Using base surface for better hierarchy
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.spacing.md), // Use design tokens
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5), // Subtle border
          width: 1,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: _getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Visual icon (MD3 best practice)
            _buildIcon(context, colorScheme),
            SizedBox(height: context.spacing.lg),
            // Header section with title and subtitle
            _buildHeader(context, theme, colorScheme),
            SizedBox(height: context.spacing.md), // Reduced spacing between header and button
            // Primary action button
            _buildPrimaryAction(context, theme, colorScheme, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.spacing.lg),
      ),
      child: Icon(
        Icons.add_circle_outline,
        size: 32,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Title with enhanced MD3 typography
        Text(
          'Ready to start?',
          style: _getResponsiveTextStyle(
            context,
            theme.textTheme.headlineSmall!, // Larger for better hierarchy
          ).copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing.sm),
        // Enhanced subtitle with personality
        Text(
          'Create your first feedback session and start gathering valuable insights from your facilitation.',
          style: _getResponsiveTextStyle(
            context,
            theme.textTheme.bodyLarge!, // Slightly larger for readability
          ).copyWith(
            color: colorScheme.onSurfaceVariant, // Better contrast
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPrimaryAction(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isCompact) {
    // Enhanced MD3 button with responsive sizing
    final buttonHeight = _getResponsiveButtonHeight(context);
    final buttonPadding = _getResponsiveButtonPadding(context);
    
    return SizedBox(
      height: buttonHeight,
      child: FilledButton.icon(
        onPressed: () {
          context.read<NavigationProvider>().navigateTo('/session_create');
        },
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.spacing.xl + context.spacing.xs),
          ),
          padding: buttonPadding,
          minimumSize: Size(120, buttonHeight), // Ensure minimum touch target
        ),
        icon: Icon(
          Icons.add,
          size: 20,
        ),
        label: Text(
          'Create session',
          style: _getResponsiveTextStyle(
            context,
            theme.textTheme.labelLarge!,
          ).copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  double _getResponsiveButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return context.spacing.xxxl; // Mobile - minimum touch target
    } else if (width < 840) {
      return context.spacing.xxxl + context.spacing.xs; // Tablet
    } else {
      return context.spacing.xxxl + context.spacing.sm; // Desktop
    }
  }

  EdgeInsets _getResponsiveButtonPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return EdgeInsets.symmetric(
        horizontal: context.spacing.lg + context.spacing.xs,
        vertical: context.spacing.md,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: context.spacing.xl,
        vertical: context.spacing.lg,
      );
    }
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      // Mobile: Tighter vertical padding to reduce space above/below content
      return EdgeInsets.symmetric(
        horizontal: context.spacing.lg, // 16px
        vertical: context.spacing.lg,   // 16px (reduced from 24px)
      );
    } else if (width < 840) {
      // Tablet: Medium padding for tablet screens
      return EdgeInsets.symmetric(
        horizontal: context.spacing.xl, // 24px
        vertical: context.spacing.lg + context.spacing.xs,   // 20px (reduced from 32px)
      );
    } else {
      // Desktop: More generous padding for large screens
      return EdgeInsets.symmetric(
        horizontal: context.spacing.xxl, // 32px
        vertical: context.spacing.xl,   // 24px (reduced from 40px)
      );
    }
  }

  TextStyle _getResponsiveTextStyle(BuildContext context, TextStyle baseStyle) {
    final width = MediaQuery.of(context).size.width;
    final double fontSize = baseStyle.fontSize ?? 16.0;
    
    double scaleFactor;
    if (width < 600) {
      scaleFactor = 0.875; // 12.5% smaller on mobile
    } else if (width < 840) {
      scaleFactor = 0.95;  // 5% smaller on tablet
    } else {
      scaleFactor = 1.0;   // Full size on desktop
    }
    
    return baseStyle.copyWith(
      fontSize: fontSize * scaleFactor,
    );
  }
}