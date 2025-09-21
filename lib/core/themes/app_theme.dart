import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'spacing_theme.dart';

/// Theme variants available in the app
enum ThemeVariant {
  light,
  dark,
  pinkDark,
}

/// App Theme Manager
class AppTheme {
  static ThemeData getTheme(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.light:
        return _createTheme(AppColorSchemes.light, Brightness.light);
      case ThemeVariant.dark:
        return _createTheme(AppColorSchemes.dark, Brightness.dark);
      case ThemeVariant.pinkDark:
        return _createTheme(AppColorSchemes.pinkDark, Brightness.dark);
    }
  }
  
  static ThemeData _createTheme(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: DesignTokens.plainFont, // Default to Roboto for UI components
      useMaterial3: true,
      
      // Text Theme using design tokens
      textTheme: TextTheme(
        displayLarge: DesignTokens.displayLarge.copyWith(color: colorScheme.onSurface),
        displayMedium: DesignTokens.displayMedium.copyWith(color: colorScheme.onSurface),
        displaySmall: DesignTokens.displaySmall.copyWith(color: colorScheme.onSurface),
        headlineLarge: DesignTokens.headlineLarge.copyWith(color: colorScheme.onSurface),
        headlineMedium: DesignTokens.headlineMedium.copyWith(color: colorScheme.onSurface),
        headlineSmall: DesignTokens.headlineSmall.copyWith(color: colorScheme.onSurface),
        titleLarge: DesignTokens.titleLarge.copyWith(color: colorScheme.onSurface),
        titleMedium: DesignTokens.titleMedium.copyWith(color: colorScheme.onSurface),
        titleSmall: DesignTokens.titleSmall.copyWith(color: colorScheme.onSurface),
        labelLarge: DesignTokens.labelLarge.copyWith(color: colorScheme.onSurface),
        labelMedium: DesignTokens.labelMedium.copyWith(color: colorScheme.onSurface),
        labelSmall: DesignTokens.labelSmall.copyWith(color: colorScheme.onSurface),
        bodyLarge: DesignTokens.bodyLarge.copyWith(color: colorScheme.onSurface),
        bodyMedium: DesignTokens.bodyMedium.copyWith(color: colorScheme.onSurface),
        bodySmall: DesignTokens.bodySmall.copyWith(color: colorScheme.onSurface),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: DesignTokens.elevation1,
        centerTitle: false,
        titleTextStyle: DesignTokens.titleLarge.copyWith(color: colorScheme.onSurface),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: DesignTokens.elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
        margin: const EdgeInsets.all(DesignTokens.spacing8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: DesignTokens.elevation1,
          padding: DesignTokens.buttonMediumPadding,
          minimumSize: const Size(0, DesignTokens.buttonMediumHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      
      // Filled Button Theme - Matches Figma design with circular radius
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing32,
            vertical: DesignTokens.spacing16,
          ),
          minimumSize: const Size(120, 56), // Larger size for prominent actions
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusCircular),
          ),
          textStyle: DesignTokens.headlineSmall, // Matches Figma 24px font
          elevation: 0,
        ).copyWith(
          // Material 3 interaction states
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return colorScheme.onPrimary.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.focused)) {
                return colorScheme.onPrimary.withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.pressed)) {
                return colorScheme.onPrimary.withValues(alpha: 0.12);
              }
              return null;
            },
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: DesignTokens.buttonMediumPadding,
          minimumSize: const Size(0, DesignTokens.buttonMediumHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: DesignTokens.buttonSmallPadding,
          minimumSize: const Size(0, DesignTokens.buttonSmallHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
          textStyle: DesignTokens.labelLarge,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.all(DesignTokens.spacing16),
        labelStyle: DesignTokens.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: DesignTokens.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: DesignTokens.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: DesignTokens.elevation2,
      ),
      
      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.onSurface),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: DesignTokens.labelMedium.copyWith(color: colorScheme.onSurface),
        unselectedLabelTextStyle: DesignTokens.labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      
      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevation1,
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
          vertical: DesignTokens.spacing8,
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        titleTextStyle: DesignTokens.headlineSmall.copyWith(color: colorScheme.onSurface),
        contentTextStyle: DesignTokens.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevation2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusLarge),
          ),
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: DesignTokens.labelLarge.copyWith(color: colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing12,
          vertical: DesignTokens.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Theme Extensions
      extensions: <ThemeExtension<dynamic>>[
        SpacingTheme.defaultTheme,
      ],
    );
  }
}

/// Extension to add surfaceContainer to ColorScheme
extension ColorSchemeExtension on ColorScheme {
  Color get surfaceContainer {
    switch (brightness) {
      case Brightness.light:
        return DesignTokens.lightSurfaceContainer;
      case Brightness.dark:
        // Could add logic to detect pink dark theme here if needed
        return DesignTokens.darkSurfaceContainer;
    }
  }

  // Semantic performance colors
  Color get success {
    switch (brightness) {
      case Brightness.light:
        return const Color(0xFF88CA5E); // Thriving Green
      case Brightness.dark:
        return const Color(0xFF88CA5E); // Thriving Green
    }
  }

  Color get positive {
    switch (brightness) {
      case Brightness.light:
        return const Color(0xFF5F9B9A); // Growth Blue
      case Brightness.dark:
        return const Color(0xFF5F9B9A); // Growth Blue
    }
  }

  Color get caution {
    switch (brightness) {
      case Brightness.light:
        return const Color(0xFFfea303); // Attention Orange
      case Brightness.dark:
        return const Color(0xFFfea303); // Attention Orange
    }
  }

  Color get critical {
    switch (brightness) {
      case Brightness.light:
        return const Color(0xFFff2768); // Alert Red
      case Brightness.dark:
        return const Color(0xFFff2768); // Alert Red
    }
  }

  // Legacy performance color getters for backward compatibility
  Color get performanceExcellent => success;
  Color get performanceGood => positive;
  Color get performanceNeedsImprovement => caution;
  Color get performancePoor => critical;

  // Validation and notification color variations
  // Success variations (green family - #88CA5E base)
  Color get successContainer => const Color(0xFF2F4F1B); // Dark green background
  Color get onSuccessContainer => const Color(0xFFC7EEA9); // Light green text
  Color get successSurface => const Color(0xFF373A33); // Dark green surface

  // Positive variations (blue family - #5F9B9A base)
  Color get positiveContainer => const Color(0xFF1E4E4E); // Dark blue background
  Color get onPositiveContainer => const Color(0xFFBBECEB); // Light blue text
  Color get positiveSurface => const Color(0xFF343A3A); // Dark blue surface

  // Caution variations (orange family - #fea303 base)
  Color get cautionContainer => const Color(0xFFFFF4E6); // Light orange background
  Color get onCautionContainer => const Color(0xFFFFDDB8); // Light orange text
  Color get cautionSurface => const Color(0xFF403830); // Dark orange surface

  // Critical variations (red family - #ff2768 base)
  Color get criticalContainer => const Color(0xFF72333E); // Dark red background
  Color get onCriticalContainer => const Color(0xFFFFD9DD); // Light red text
  Color get criticalSurface => const Color(0xFF413738); // Dark red surface
}

/// Extension to easily access current theme colors
extension BuildContextThemeExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}