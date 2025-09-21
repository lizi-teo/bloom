import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Extension to provide easy access to typography variants
/// Matches Figma's emphasized text style system
extension TypographyExtension on TextTheme {
  // Display variants
  TextStyle get displayLargeEmphasized => DesignTokens.displayLargeEmphasized;
  TextStyle get displayMediumEmphasized => DesignTokens.displayMediumEmphasized;
  TextStyle get displaySmallEmphasized => DesignTokens.displaySmallEmphasized;
  
  // Headline variants
  TextStyle get headlineLargeEmphasized => DesignTokens.headlineLargeEmphasized;
  TextStyle get headlineMediumEmphasized => DesignTokens.headlineMediumEmphasized;
  TextStyle get headlineSmallEmphasized => DesignTokens.headlineSmallEmphasized;
  
  // Title variants
  TextStyle get titleLargeEmphasized => DesignTokens.titleLargeEmphasized;
  TextStyle get titleMediumEmphasized => DesignTokens.titleMediumEmphasized;
  TextStyle get titleSmallEmphasized => DesignTokens.titleSmallEmphasized;
  
  // Label variants
  TextStyle get labelLargeEmphasized => DesignTokens.labelLargeEmphasized;
  TextStyle get labelMediumEmphasized => DesignTokens.labelMediumEmphasized;
  TextStyle get labelSmallEmphasized => DesignTokens.labelSmallEmphasized;
  
  // Body variants
  TextStyle get bodyLargeEmphasized => DesignTokens.bodyLargeEmphasized;
  TextStyle get bodyMediumEmphasized => DesignTokens.bodyMediumEmphasized;
  TextStyle get bodySmallEmphasized => DesignTokens.bodySmallEmphasized;
}

/// Helper to map Figma variable names to Flutter TextStyles
/// Use this when converting Figma designs to Flutter code
class FigmaTypographyMapper {
  static TextStyle? fromFigmaVariable(String figmaVar) {
    // Remove M3/ prefix if present
    final cleanVar = figmaVar.replaceAll('M3/', '').replaceAll('/', '-');
    
    // Map Figma variables to Flutter TextStyles
    final mappings = {
      // Regular styles
      'display-large': DesignTokens.displayLarge,
      'display-medium': DesignTokens.displayMedium,
      'display-small': DesignTokens.displaySmall,
      'headline-large': DesignTokens.headlineLarge,
      'headline-medium': DesignTokens.headlineMedium,
      'headline-small': DesignTokens.headlineSmall,
      'title-large': DesignTokens.titleLarge,
      'title-medium': DesignTokens.titleMedium,
      'title-small': DesignTokens.titleSmall,
      'label-large': DesignTokens.labelLarge,
      'label-medium': DesignTokens.labelMedium,
      'label-small': DesignTokens.labelSmall,
      'body-large': DesignTokens.bodyLarge,
      'body-medium': DesignTokens.bodyMedium,
      'body-small': DesignTokens.bodySmall,
      
      // Emphasized styles
      'display-large-emphasized': DesignTokens.displayLargeEmphasized,
      'display-medium-emphasized': DesignTokens.displayMediumEmphasized,
      'display-small-emphasized': DesignTokens.displaySmallEmphasized,
      'headline-large-emphasized': DesignTokens.headlineLargeEmphasized,
      'headline-medium-emphasized': DesignTokens.headlineMediumEmphasized,
      'headline-small-emphasized': DesignTokens.headlineSmallEmphasized,
      'title-large-emphasized': DesignTokens.titleLargeEmphasized,
      'title-medium-emphasized': DesignTokens.titleMediumEmphasized,
      'title-small-emphasized': DesignTokens.titleSmallEmphasized,
      'label-large-emphasized': DesignTokens.labelLargeEmphasized,
      'label-medium-emphasized': DesignTokens.labelMediumEmphasized,
      'label-small-emphasized': DesignTokens.labelSmallEmphasized,
      'body-large-emphasized': DesignTokens.bodyLargeEmphasized,
      'body-medium-emphasized': DesignTokens.bodyMediumEmphasized,
      'body-small-emphasized': DesignTokens.bodySmallEmphasized,
    };
    
    return mappings[cleanVar];
  }
  
  /// Get text style from Figma's Static/* variables
  static TextStyle? fromStaticVariable(String staticVar) {
    // Map Static/Display/Large etc to Flutter TextStyles
    final cleanVar = staticVar
        .replaceAll('Static/', '')
        .replaceAll(' ', '-')
        .toLowerCase();
    
    return fromFigmaVariable(cleanVar);
  }
}