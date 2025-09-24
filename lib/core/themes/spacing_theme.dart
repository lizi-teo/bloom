import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'design_tokens.dart';
import '../utils/responsive_utils.dart';

/// Spacing theme extension to provide consistent spacing through Flutter Theme
@immutable
class SpacingTheme extends ThemeExtension<SpacingTheme> {
  const SpacingTheme({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.lgPlus,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  /// Extra small spacing - 4dp - Micro adjustments, icon spacing
  final double xs;

  /// Small spacing - 8dp - Component internal padding
  final double sm;

  /// Medium spacing - 12dp - Small component gaps
  final double md;

  /// Large spacing - 16dp - Standard content padding
  final double lg;

  /// Large plus spacing - 20dp - Content padding with extra space
  final double lgPlus;

  /// Extra large spacing - 24dp - Section separation
  final double xl;

  /// Extra extra large spacing - 32dp - Large content blocks
  final double xxl;

  /// Extra extra extra large spacing - 48dp - Major page sections
  final double xxxl;

  /// Default spacing theme using DesignTokens
  static const SpacingTheme defaultTheme = SpacingTheme(
    xs: DesignTokens.spacing4,
    sm: DesignTokens.spacing8,
    md: DesignTokens.spacing12,
    lg: DesignTokens.spacing16,
    lgPlus: DesignTokens.spacing20,
    xl: DesignTokens.spacing24,
    xxl: DesignTokens.spacing32,
    xxxl: DesignTokens.spacing48,
  );

  @override
  SpacingTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? lgPlus,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return SpacingTheme(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      lgPlus: lgPlus ?? this.lgPlus,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  SpacingTheme lerp(ThemeExtension<SpacingTheme>? other, double t) {
    if (other is! SpacingTheme) {
      return this;
    }

    return SpacingTheme(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      lgPlus: lerpDouble(lgPlus, other.lgPlus, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      xxxl: lerpDouble(xxxl, other.xxxl, t)!,
    );
  }

  /// Helper method to get spacing by name
  double getSpacing(String name) {
    switch (name) {
      case 'xs':
        return xs;
      case 'sm':
        return sm;
      case 'md':
        return md;
      case 'lg':
        return lg;
      case 'lgPlus':
        return lgPlus;
      case 'xl':
        return xl;
      case 'xxl':
        return xxl;
      case 'xxxl':
        return xxxl;
      default:
        return lg; // Default to standard content padding
    }
  }
}

/// Extension to easily access spacing from BuildContext
extension SpacingThemeExtension on BuildContext {
  SpacingTheme get spacing => Theme.of(this).extension<SpacingTheme>() ?? SpacingTheme.defaultTheme;

  /// Standardized page edge padding based on screen size:
  /// - Compact (mobile): 20px (16px for budget Android)
  /// - Medium (tablet): 24px
  /// - Expanded (desktop): 32px
  EdgeInsets get pageEdgePadding {
    final screenSize = getScreenSize(this);
    switch (screenSize) {
      case ScreenSize.compact:
        // Use smaller padding for budget Android devices (360dp width)
        final isBudget = isLikelyBudgetAndroid(this);
        return EdgeInsets.all(isBudget ? spacing.lg : spacing.lgPlus); // 16px or 20px
      case ScreenSize.medium:
        return EdgeInsets.all(spacing.xl); // 24px
      case ScreenSize.expanded:
        return EdgeInsets.all(spacing.xxl); // 32px
    }
  }
}