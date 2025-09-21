import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Utility class to validate design tokens
class TokenValidator {
  /// Validate that all required colors are defined and not using placeholder values
  static List<String> validateColors() {
    final issues = <String>[];
    
    // Check for common placeholder hex values that should be replaced
    const placeholderValues = [
      0xFF6750A4, // Common Material 3 purple placeholder
      0xFFFFFFFF, // White (may be legitimate)
      0xFF000000, // Black (may be legitimate)
    ];
    
    final colorTests = [
      ('Light Primary', DesignTokens.lightPrimary.toARGB32()),
      ('Light Secondary', DesignTokens.lightSecondary.toARGB32()),
      ('Light Tertiary', DesignTokens.lightTertiary.toARGB32()),
      ('Dark Primary', DesignTokens.darkPrimary.toARGB32()),
      ('Dark Secondary', DesignTokens.darkSecondary.toARGB32()),
      ('Dark Tertiary', DesignTokens.darkTertiary.toARGB32()),
      ('Pink Dark Primary', DesignTokens.pinkDarkPrimary.toARGB32()),
    ];
    
    for (final (name, value) in colorTests) {
      if (placeholderValues.contains(value) && !['White', 'Black'].any(name.contains)) {
        issues.add('$name may be using a placeholder value: ${value.toRadixString(16).toUpperCase()}');
      }
    }
    
    return issues;
  }
  
  /// Validate typography scale consistency
  static List<String> validateTypography() {
    final issues = <String>[];
    
    // Check for reasonable font sizes
    final fontSizeTests = [
      ('Display Large', DesignTokens.displayLarge.fontSize ?? 0),
      ('Display Medium', DesignTokens.displayMedium.fontSize ?? 0),
      ('Display Small', DesignTokens.displaySmall.fontSize ?? 0),
      ('Headline Large', DesignTokens.headlineLarge.fontSize ?? 0),
      ('Body Large', DesignTokens.bodyLarge.fontSize ?? 0),
      ('Body Small', DesignTokens.bodySmall.fontSize ?? 0),
    ];
    
    for (int i = 0; i < fontSizeTests.length - 1; i++) {
      final current = fontSizeTests[i];
      final next = fontSizeTests[i + 1];
      
      if (current.$2 <= next.$2) {
        issues.add('${current.$1} (${current.$2}px) should be larger than ${next.$1} (${next.$2}px)');
      }
    }
    
    // Check for default Roboto font
    if (DesignTokens.primaryFontFamily == 'Roboto') {
      issues.add('Primary font family is still set to default "Roboto" - verify this is correct for your design');
    }
    
    return issues;
  }
  
  /// Validate spacing scale
  static List<String> validateSpacing() {
    final issues = <String>[];
    
    final spacingTests = [
      ('spacing4', DesignTokens.spacing4),
      ('spacing8', DesignTokens.spacing8),
      ('spacing12', DesignTokens.spacing12),
      ('spacing16', DesignTokens.spacing16),
      ('spacing24', DesignTokens.spacing24),
      ('spacing32', DesignTokens.spacing32),
    ];
    
    for (int i = 0; i < spacingTests.length - 1; i++) {
      final current = spacingTests[i];
      final next = spacingTests[i + 1];
      
      if (current.$2 >= next.$2) {
        issues.add('${current.$1} (${current.$2}) should be smaller than ${next.$1} (${next.$2})');
      }
    }
    
    return issues;
  }
  
  /// Run all validation checks
  static Map<String, List<String>> validateAll() {
    return {
      'colors': validateColors(),
      'typography': validateTypography(),
      'spacing': validateSpacing(),
    };
  }
  
  /// Print validation report to console
  static void printValidationReport() {
    final results = validateAll();
    bool hasIssues = false;
    
    debugPrint('🔍 Design Token Validation Report');
    debugPrint('=' * 40);
    
    for (final category in results.keys) {
      final issues = results[category]!;
      debugPrint('\n📊 ${category.toUpperCase()}:');
      
      if (issues.isEmpty) {
        debugPrint('  ✅ No issues found');
      } else {
        hasIssues = true;
        for (final issue in issues) {
          debugPrint('  ⚠️  $issue');
        }
      }
    }
    
    debugPrint('\n${'=' * 40}');
    if (hasIssues) {
      debugPrint('❌ Validation completed with issues. Please review the warnings above.');
      debugPrint('💡 These may be expected if you have not yet extracted values from Figma.');
    } else {
      debugPrint('✅ All validations passed! Your design tokens look good.');
    }
  }
  
  /// Get color contrast ratio (simplified calculation)
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Check color accessibility (WCAG contrast ratios)
  static List<String> validateAccessibility() {
    final issues = <String>[];
    
    // Check key color combinations for accessibility
    final contrastTests = [
      ('Light: Primary on Primary Container', 
       DesignTokens.lightPrimary, 
       DesignTokens.lightPrimaryContainer),
      ('Dark: Primary on Primary Container', 
       DesignTokens.darkPrimary, 
       DesignTokens.darkPrimaryContainer),
      ('Light: On Surface on Surface', 
       DesignTokens.lightOnSurface, 
       DesignTokens.lightSurface),
      ('Dark: On Surface on Surface', 
       DesignTokens.darkOnSurface, 
       DesignTokens.darkSurface),
    ];
    
    for (final (name, foreground, background) in contrastTests) {
      final ratio = getContrastRatio(foreground, background);
      if (ratio < 3.0) { // WCAG AA minimum for large text
        issues.add('$name has low contrast ratio: ${ratio.toStringAsFixed(1)}:1 (should be ≥3:1)');
      }
    }
    
    return issues;
  }
}