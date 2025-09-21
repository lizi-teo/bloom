import 'package:flutter/material.dart';

/// Design Tokens extracted from Figma
/// Organized to match Figma's variable structure for easy mapping
/// When referencing Figma designs, look for:
/// - Static/* variables for typography
/// - M3/* variables for Material 3 mappings
/// - Schemes/* for color schemes
class DesignTokens {
  // LIGHT THEME COLORS - From Figma M3 Light
  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF4F378A);
  
  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF4A4459);
  
  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF633B48);
  
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightOnErrorContainer = Color(0xFF852221);
  
  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceContainer = Color(0xFFF3EDF7); // From Figma surface container light
  static const Color lightSurfaceContainerHigh = Color(0xFFECE6F0); // From Figma surface container high light
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);
  
  // DARK THEME COLORS - From Figma M3 Dark
  static const Color darkPrimary = Color(0xFF9E8AEF);
  static const Color darkOnPrimary = Color(0xFF381E72);
  static const Color darkPrimaryContainer = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);
  
  static const Color darkSecondary = Color(0xFFCCC2DC);
  static const Color darkOnSecondary = Color(0xFF332D41);
  static const Color darkSecondaryContainer = Color(0xFF4A4458);
  static const Color darkOnSecondaryContainer = Color(0xFFE8DEF8);
  
  static const Color darkTertiary = Color(0xFFEFB8C8);
  static const Color darkOnTertiary = Color(0xFF492532);
  static const Color darkTertiaryContainer = Color(0xFF633B48);
  static const Color darkOnTertiaryContainer = Color(0xFFFFD8E4);
  
  static const Color darkError = Color(0xFFF2B8B5);
  static const Color darkErrorContainer = Color(0xFF8C1D18);
  static const Color darkOnError = Color(0xFF601410);
  static const Color darkOnErrorContainer = Color(0xFFF9DEDC);
  
  static const Color darkBackground = Color(0xFF141218);
  static const Color darkOnBackground = Color(0xFFE6E0E9);
  static const Color darkSurface = Color(0xFF141218);
  static const Color darkOnSurface = Color(0xFFE6E0E9);
  static const Color darkSurfaceContainer = Color(0xFF211F26); // From Figma surface container dark
  static const Color darkSurfaceContainerHigh = Color(0xFF2B2930); // From Figma surface container high dark
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);
  
  // PINK DARK THEME COLORS - From Figma M3 Pink DT
  static const Color pinkDarkPrimary = Color(0xFFFEB0D1);
  static const Color pinkDarkOnPrimary = Color(0xFF531D39);
  static const Color pinkDarkPrimaryContainer = Color(0xFF6D3350);
  static const Color pinkDarkOnPrimaryContainer = Color(0xFFFFD8E6);
  
  static const Color pinkDarkSecondary = Color(0xFFE1BDCA);
  static const Color pinkDarkOnSecondary = Color(0xFF412A34);
  static const Color pinkDarkSecondaryContainer = Color(0xFF59404A);
  static const Color pinkDarkOnSecondaryContainer = Color(0xFFFED9E6);
  
  static const Color pinkDarkTertiary = Color(0xFFF2BB98);
  static const Color pinkDarkOnTertiary = Color(0xFF49280F);
  static const Color pinkDarkTertiaryContainer = Color(0xFF633E23);
  static const Color pinkDarkOnTertiaryContainer = Color(0xFFFFDCC6);
  
  static const Color pinkDarkError = Color(0xFFF2B8B5);
  static const Color pinkDarkErrorContainer = Color(0xFF8C1D18);
  static const Color pinkDarkOnError = Color(0xFF601410);
  static const Color pinkDarkOnErrorContainer = Color(0xFFF9DEDC);
  
  static const Color pinkDarkBackground = Color(0xFF141218);
  static const Color pinkDarkOnBackground = Color(0xFFE6E0E9);
  static const Color pinkDarkSurface = Color(0xFF191114);
  static const Color pinkDarkOnSurface = Color(0xFFEEDFE3);
  static const Color pinkDarkSurfaceContainer = Color(0xFF211F26); // From Figma surface container
  static const Color pinkDarkSurfaceVariant = Color(0xFF3B3235);
  static const Color pinkDarkOnSurfaceVariant = Color(0xFFD4C2C7);
  static const Color pinkDarkOutline = Color(0xFF9D8C92);
  static const Color pinkDarkOutlineVariant = Color(0xFF504348);
  
  // TYPOGRAPHY FOUNDATION - Matches Figma's Font theme - Baseline
  // Brand font should be Questrial when properly configured
  static const String brandFont = 'Questrial'; // Static-Font-Brand
  static const String plainFont = 'Roboto'; // Static-Font-Plain
  static const String primaryFontFamily = brandFont; // Alias for primary font
  
  // Fallback fonts when brand font is not available
  // Questrial is a clean, geometric sans-serif, so we use similar system fonts
  static const String brandFontFallback = '.SF UI Display'; // iOS fallback
  static const String brandFontFallbackAndroid = 'sans-serif'; // Android fallback
  
  // Font Weights - Matches Figma's weight system
  static const FontWeight weightRegular = FontWeight.w400; // Static-Weight-Regular
  static const FontWeight weightMedium = FontWeight.w500; // Static-Weight-Medium
  static const FontWeight weightBold = FontWeight.w600; // Static-Weight-Bold (SemiBold)
  
  // TYPOGRAPHY SCALE - Matches Figma's Typescale - Baseline
  // Each style has regular and emphasized variants
  
  // Display Text Styles - Brand Font (Questrial)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: brandFont,
    fontSize: 57, // Static-Display-Large-Size
    fontWeight: weightRegular, // Static-Display-Large-Weight
    letterSpacing: -0.25, // Static-Display-Large-Tracking
    height: 64 / 57, // Static-Display-Large-Line-Height / Size
  );
  
  static const TextStyle displayLargeEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 57,
    fontWeight: weightMedium, // Static-Display-Large-Weight-emphasized
    letterSpacing: -0.25,
    height: 64 / 57,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: brandFont,
    fontSize: 45, // Static-Display-Medium-Size
    fontWeight: weightRegular, // Static-Display-Medium-Weight
    letterSpacing: 0, // Static-Display-Medium-Tracking
    height: 52 / 45, // Static-Display-Medium-Line-Height / Size
  );
  
  static const TextStyle displayMediumEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 45,
    fontWeight: weightMedium, // Static-Display-Medium-Weight-emphasized
    letterSpacing: 0,
    height: 52 / 45,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: brandFont,
    fontSize: 36, // Static-Display-Small-Size
    fontWeight: weightRegular, // Static-Display-Small-Weight
    letterSpacing: 0, // Static-Display-Small-Tracking
    height: 44 / 36, // Static-Display-Small-Line-Height / Size
  );
  
  static const TextStyle displaySmallEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 36,
    fontWeight: weightMedium, // Static-Display-Small-Weight-emphasized
    letterSpacing: 0,
    height: 44 / 36,
  );
  
  // Headline Text Styles - Brand Font (Questrial)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: brandFont,
    fontSize: 32, // Static-Headline-Large-Size
    fontWeight: weightRegular, // Static-Headline-Large-Weight
    letterSpacing: 0, // Static-Headline-Large-Tracking
    height: 40 / 32, // Static-Headline-Large-Line-Height / Size
  );
  
  static const TextStyle headlineLargeEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 32,
    fontWeight: weightMedium, // Static-Headline-Large-Weight-emphasized
    letterSpacing: 0,
    height: 40 / 32,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: brandFont,
    fontSize: 28, // Static-Headline-Medium-Size
    fontWeight: weightRegular, // Static-Headline-Medium-Weight
    letterSpacing: 0, // Static-Headline-Medium-Tracking
    height: 36 / 28, // Static-Headline-Medium-Line-Height / Size
  );
  
  static const TextStyle headlineMediumEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 28,
    fontWeight: weightMedium, // Static-Headline-Medium-Weight-emphasized
    letterSpacing: 0,
    height: 36 / 28,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: brandFont,
    fontSize: 24, // Static-Headline-Small-Size
    fontWeight: weightRegular, // Static-Headline-Small-Weight
    letterSpacing: 0, // Static-Headline-Small-Tracking
    height: 32 / 24, // Static-Headline-Small-Line-Height / Size
  );
  
  static const TextStyle headlineSmallEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 24,
    fontWeight: weightMedium, // Static-Headline-Small-Weight-emphasized
    letterSpacing: 0,
    height: 32 / 24,
  );
  
  // Title Text Styles - Brand Font (Questrial)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: brandFont,
    fontSize: 22, // Static-Title-Large-Size
    fontWeight: weightRegular, // Static-Title-Large-Weight
    letterSpacing: 0, // Static-Title-Large-Tracking
    height: 28 / 22, // Static-Title-Large-Line-Height / Size
  );
  
  static const TextStyle titleLargeEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 22,
    fontWeight: weightMedium, // Static-Title-Large-Weight-emphasized
    letterSpacing: 0,
    height: 28 / 22,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: brandFont,
    fontSize: 16, // Static-Title-Medium-Size
    fontWeight: weightRegular, // Static-Title-Medium-Weight
    letterSpacing: 0.15, // Static-Title-Medium-Tracking
    height: 24 / 16, // Static-Title-Medium-Line-Height / Size
  );
  
  static const TextStyle titleMediumEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 16,
    fontWeight: weightMedium, // Static-Title-Medium-Weight-emphasized
    letterSpacing: 0.15,
    height: 24 / 16,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: brandFont,
    fontSize: 14, // Static-Title-Small-Size
    fontWeight: weightRegular, // Static-Title-Small-Weight
    letterSpacing: 0.1, // Static-Title-Small-Tracking
    height: 20 / 14, // Static-Title-Small-Line-Height / Size
  );
  
  static const TextStyle titleSmallEmphasized = TextStyle(
    fontFamily: brandFont,
    fontSize: 14,
    fontWeight: weightMedium, // Static-Title-Small-Weight-emphasized
    letterSpacing: 0.1,
    height: 20 / 14,
  );
  
  // Label Text Styles - Plain Font (Roboto)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: plainFont,
    fontSize: 14, // Static-Label-Large-Size
    fontWeight: weightMedium, // Static-Label-Large-Weight
    letterSpacing: 0.1, // Static-Label-Large-Tracking
    height: 20 / 14, // Static-Label-Large-Line-Height / Size
  );
  
  static const TextStyle labelLargeEmphasized = TextStyle(
    fontFamily: plainFont,
    fontSize: 14,
    fontWeight: weightBold, // Static-Label-Large-Weight-emphasized
    letterSpacing: 0.1,
    height: 20 / 14,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: plainFont,
    fontSize: 12, // Static-Label-Medium-Size
    fontWeight: weightMedium, // Static-Label-Medium-Weight
    letterSpacing: 0.5, // Static-Label-Medium-Tracking
    height: 16 / 12, // Static-Label-Medium-Line-Height / Size
  );
  
  static const TextStyle labelMediumEmphasized = TextStyle(
    fontFamily: plainFont,
    fontSize: 12,
    fontWeight: weightBold, // Static-Label-Medium-Weight-emphasized
    letterSpacing: 0.5,
    height: 16 / 12,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: plainFont,
    fontSize: 11, // Static-Label-Small-Size
    fontWeight: weightMedium, // Static-Label-Small-Weight
    letterSpacing: 0.5, // Static-Label-Small-Tracking
    height: 16 / 11, // Static-Label-Small-Line-Height / Size
  );
  
  static const TextStyle labelSmallEmphasized = TextStyle(
    fontFamily: plainFont,
    fontSize: 11,
    fontWeight: weightBold, // Static-Label-Small-Weight-emphasized
    letterSpacing: 0.5,
    height: 16 / 11,
  );
  
  // Body Text Styles - Plain Font (Roboto)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: plainFont,
    fontSize: 16, // Static-Body-Large-Size
    fontWeight: weightRegular, // Static-Body-Large-Weight
    letterSpacing: 0.5, // Static-Body-Large-Tracking
    height: 24 / 16, // Static-Body-Large-Line-Height / Size
  );
  
  static const TextStyle bodyLargeEmphasized = TextStyle(
    fontFamily: plainFont,
    fontSize: 16,
    fontWeight: weightMedium, // Static-Body-Large-Weight-emphasized
    letterSpacing: 0.5,
    height: 24 / 16,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: plainFont,
    fontSize: 14, // Static-Body-Medium-Size
    fontWeight: weightRegular, // Static-Body-Medium-Weight
    letterSpacing: 0.25, // Static-Body-Medium-Tracking
    height: 20 / 14, // Static-Body-Medium-Line-Height / Size
  );
  
  static const TextStyle bodyMediumEmphasized = TextStyle(
    fontFamily: plainFont,
    fontSize: 14,
    fontWeight: weightMedium, // Static-Body-Medium-Weight-emphasized
    letterSpacing: 0.25,
    height: 20 / 14,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: plainFont,
    fontSize: 12, // Static-Body-Small-Size
    fontWeight: weightRegular, // Static-Body-Small-Weight
    letterSpacing: 0.4, // Static-Body-Small-Tracking
    height: 16 / 12, // Static-Body-Small-Line-Height / Size
  );
  
  static const TextStyle bodySmallEmphasized = TextStyle(
    fontFamily: plainFont,
    fontSize: 12,
    fontWeight: weightMedium, // Static-Body-Small-Weight-emphasized
    letterSpacing: 0.4,
    height: 16 / 12,
  );
  
  // SPACING TOKENS
  // TODO: Extract actual spacing values from Figma
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing30 = 30.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // BORDER RADIUS TOKENS
  // TODO: Extract actual radius values from Figma
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 1000.0;
  
  // Corner radius aliases for backward compatibility
  static const double cornerSmall = radiusSmall;
  static const double cornerLarge = radiusLarge;
  static const double cornerFull = radiusCircular;
  
  // ELEVATION TOKENS
  // TODO: Extract actual elevation values from Figma
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 3.0;
  static const double elevation3 = 6.0;
  static const double elevation4 = 8.0;
  static const double elevation5 = 12.0;
  
  // BUTTON SIZE TOKENS - Material Design 3 Standards
  // Small Button (32dp height)
  static const double buttonSmallHeight = 32.0;
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  
  // Medium Button (40dp height) - Default
  static const double buttonMediumHeight = 40.0;
  static const EdgeInsets buttonMediumPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 10.0,
  );
  
  // Large Button (48dp height)
  static const double buttonLargeHeight = 48.0;
  static const EdgeInsets buttonLargePadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  
  // Extra Large Button (56dp height) - for prominent mobile touch targets
  static const double buttonExtraLargeHeight = 56.0;
  static const EdgeInsets buttonExtraLargePadding = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 16.0,
  );

  // Touch Target - Material Design 3 minimum touch target
  static const double minimumTouchTarget = 48.0;

  // FIGMA BUTTON SPECIFICATIONS - Extracted from Figma design system
  // Button Size Configurations - Matches Figma button component specs exactly
  
  // XSmall Button (20dp height) - matches Figma XSmall
  static const double buttonXSmallHeight = 20.0;
  static const EdgeInsets buttonXSmallPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
  static const double buttonXSmallIconSize = 20.0;
  static const double buttonXSmallGap = 4.0;
  
  // Small Button (28dp height) - matches Figma Small  
  static const double buttonSmallHeightFigma = 28.0;
  static const EdgeInsets buttonSmallPaddingFigma = EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0);
  static const double buttonSmallIconSize = 20.0;
  static const double buttonSmallGap = 8.0;
  
  // Medium Button (40dp height) - matches Figma Medium
  static const double buttonMediumHeightFigma = 40.0;
  static const EdgeInsets buttonMediumPaddingFigma = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  static const double buttonMediumIconSize = 24.0;
  static const double buttonMediumGap = 8.0;
  
  // Large Button (56dp height) - matches Figma Large
  static const double buttonLargeHeightFigma = 56.0;
  static const EdgeInsets buttonLargePaddingFigma = EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0);
  static const double buttonLargeIconSize = 32.0;
  static const double buttonLargeGap = 12.0;
  
  // XLarge Button (88dp height) - matches Figma XLarge
  static const double buttonXLargeHeight = 88.0;
  static const EdgeInsets buttonXLargePadding = EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0);
  static const double buttonXLargeIconSize = 40.0;
  static const double buttonXLargeGap = 16.0;
  
  // Button Border Radius - Shape configurations from Figma
  // Square buttons use these specific radius values
  static const double buttonRadiusXSmall = 12.0;
  static const double buttonRadiusSmall = 12.0;  
  static const double buttonRadiusMedium = 16.0;
  static const double buttonRadiusLarge = 28.0;
  static const double buttonRadiusXLarge = 28.0;
  
  // Round buttons use full radius (100px in Figma = circular)
  static const double buttonRadiusRound = 100.0;
  
  // Button Elevation - From Figma shadow specifications
  static const double buttonElevationElevated1 = 1.0; // XSmall/Small elevated
  static const double buttonElevationElevated2 = 3.0; // Medium elevated  
  static const double buttonElevationElevated3 = 6.0; // Large/XLarge elevated
  
  /// Button Style Helpers - Material Design 3 Size Variants
  /// Creates ButtonStyle for different button sizes with proper MD3 specifications
  /// 
  /// Note: All button styles automatically maintain 48dp minimum touch target
  /// through Flutter's Material Design implementation for accessibility compliance
  
  /// Small button style (32dp height) - for compact UIs and secondary actions
  static ButtonStyle buttonStyleSmall(ColorScheme colorScheme, {
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor ?? colorScheme.primary),
      foregroundColor: WidgetStateProperty.all(foregroundColor ?? colorScheme.onPrimary),
      padding: WidgetStateProperty.all(buttonSmallPadding),
      minimumSize: WidgetStateProperty.all(const Size(0, buttonSmallHeight)),
      elevation: WidgetStateProperty.all(elevation),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
      ),
      textStyle: WidgetStateProperty.all(labelLarge),
    );
  }
  
  /// Medium button style (40dp height) - default size for most actions
  static ButtonStyle buttonStyleMedium(ColorScheme colorScheme, {
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor ?? colorScheme.primary),
      foregroundColor: WidgetStateProperty.all(foregroundColor ?? colorScheme.onPrimary),
      padding: WidgetStateProperty.all(buttonMediumPadding),
      minimumSize: WidgetStateProperty.all(const Size(0, buttonMediumHeight)),
      elevation: WidgetStateProperty.all(elevation),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
      ),
      textStyle: WidgetStateProperty.all(labelLarge),
    );
  }
  
  /// Large button style (48dp height) - for prominent actions and primary CTAs
  static ButtonStyle buttonStyleLarge(ColorScheme colorScheme, {
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor ?? colorScheme.primary),
      foregroundColor: WidgetStateProperty.all(foregroundColor ?? colorScheme.onPrimary),
      padding: WidgetStateProperty.all(buttonLargePadding),
      minimumSize: WidgetStateProperty.all(const Size(0, buttonLargeHeight)),
      elevation: WidgetStateProperty.all(elevation),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
      ),
      textStyle: WidgetStateProperty.all(labelLarge),
    );
  }

  /// Extra large button style (56dp height) - for prominent mobile touch targets
  static ButtonStyle buttonStyleExtraLarge(ColorScheme colorScheme, {
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 0,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor ?? colorScheme.primary),
      foregroundColor: WidgetStateProperty.all(foregroundColor ?? colorScheme.onPrimary),
      padding: WidgetStateProperty.all(buttonExtraLargePadding),
      minimumSize: WidgetStateProperty.all(const Size(0, buttonExtraLargeHeight)),
      elevation: WidgetStateProperty.all(elevation),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
      ),
      textStyle: WidgetStateProperty.all(labelLarge),
    );
  }

  /// Material Design 3 Button Style Helpers
  /// These provide easy access to button styles that match Material 3 guidelines
  /// while using the app's design tokens.
  
  /// Primary filled button style - matches Figma design specifications
  static ButtonStyle primaryButtonStyle(ColorScheme colorScheme) {
    return FilledButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      disabledBackgroundColor: colorScheme.surfaceContainerHighest,
      disabledForegroundColor: colorScheme.onSurfaceVariant,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing32,
        vertical: spacing16,
      ),
      minimumSize: const Size(120, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCircular),
      ),
      textStyle: headlineSmall,
      elevation: 0,
    );
  }

  /// Secondary outlined button style
  static ButtonStyle secondaryButtonStyle(ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurfaceVariant,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: colorScheme.outline),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing12,
      ),
      minimumSize: const Size(120, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCircular),
      ),
      textStyle: labelLarge,
      elevation: 0,
    );
  }

  /// Tertiary text button style
  static ButtonStyle tertiaryButtonStyle(ColorScheme colorScheme) {
    return TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurfaceVariant,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing8,
      ),
      minimumSize: const Size(64, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      textStyle: labelLarge,
      elevation: 0,
    );
  }
}

/// Create ColorScheme objects for each theme variant
class AppColorSchemes {
  static ColorScheme get light => ColorScheme.light(
    primary: DesignTokens.lightPrimary,
    onPrimary: DesignTokens.lightOnPrimary,
    primaryContainer: DesignTokens.lightPrimaryContainer,
    onPrimaryContainer: DesignTokens.lightOnPrimaryContainer,
    secondary: DesignTokens.lightSecondary,
    onSecondary: DesignTokens.lightOnSecondary,
    secondaryContainer: DesignTokens.lightSecondaryContainer,
    onSecondaryContainer: DesignTokens.lightOnSecondaryContainer,
    tertiary: DesignTokens.lightTertiary,
    onTertiary: DesignTokens.lightOnTertiary,
    tertiaryContainer: DesignTokens.lightTertiaryContainer,
    onTertiaryContainer: DesignTokens.lightOnTertiaryContainer,
    error: DesignTokens.lightError,
    errorContainer: DesignTokens.lightErrorContainer,
    onError: DesignTokens.lightOnError,
    onErrorContainer: DesignTokens.lightOnErrorContainer,
    surface: DesignTokens.lightSurface,
    onSurface: DesignTokens.lightOnSurface,
    onSurfaceVariant: DesignTokens.lightOnSurfaceVariant,
    outline: DesignTokens.lightOutline,
    outlineVariant: DesignTokens.lightOutlineVariant,
  ).copyWith(
    surfaceContainer: DesignTokens.lightSurfaceContainer,
    surfaceContainerHigh: DesignTokens.lightSurfaceContainerHigh,
    surfaceContainerHighest: DesignTokens.lightSurfaceVariant,
  );
  
  static ColorScheme get dark => ColorScheme.dark(
    primary: DesignTokens.darkPrimary,
    onPrimary: DesignTokens.darkOnPrimary,
    primaryContainer: DesignTokens.darkPrimaryContainer,
    onPrimaryContainer: DesignTokens.darkOnPrimaryContainer,
    secondary: DesignTokens.darkSecondary,
    onSecondary: DesignTokens.darkOnSecondary,
    secondaryContainer: DesignTokens.darkSecondaryContainer,
    onSecondaryContainer: DesignTokens.darkOnSecondaryContainer,
    tertiary: DesignTokens.darkTertiary,
    onTertiary: DesignTokens.darkOnTertiary,
    tertiaryContainer: DesignTokens.darkTertiaryContainer,
    onTertiaryContainer: DesignTokens.darkOnTertiaryContainer,
    error: DesignTokens.darkError,
    errorContainer: DesignTokens.darkErrorContainer,
    onError: DesignTokens.darkOnError,
    onErrorContainer: DesignTokens.darkOnErrorContainer,
    surface: DesignTokens.darkSurface,
    onSurface: DesignTokens.darkOnSurface,
    onSurfaceVariant: DesignTokens.darkOnSurfaceVariant,
    outline: DesignTokens.darkOutline,
    outlineVariant: DesignTokens.darkOutlineVariant,
  ).copyWith(
    surfaceContainer: DesignTokens.darkSurfaceContainer,
    surfaceContainerHigh: DesignTokens.darkSurfaceContainerHigh,
    surfaceContainerHighest: DesignTokens.darkSurfaceVariant,
  );
  
  // Pink Dark Theme - From Figma M3 Pink DT
  static ColorScheme get pinkDark => ColorScheme.dark(
    primary: DesignTokens.pinkDarkPrimary,
    onPrimary: DesignTokens.pinkDarkOnPrimary,
    primaryContainer: DesignTokens.pinkDarkPrimaryContainer,
    onPrimaryContainer: DesignTokens.pinkDarkOnPrimaryContainer,
    secondary: DesignTokens.pinkDarkSecondary,
    onSecondary: DesignTokens.pinkDarkOnSecondary,
    secondaryContainer: DesignTokens.pinkDarkSecondaryContainer,
    onSecondaryContainer: DesignTokens.pinkDarkOnSecondaryContainer,
    tertiary: DesignTokens.pinkDarkTertiary,
    onTertiary: DesignTokens.pinkDarkOnTertiary,
    tertiaryContainer: DesignTokens.pinkDarkTertiaryContainer,
    onTertiaryContainer: DesignTokens.pinkDarkOnTertiaryContainer,
    error: DesignTokens.pinkDarkError,
    errorContainer: DesignTokens.pinkDarkErrorContainer,
    onError: DesignTokens.pinkDarkOnError,
    onErrorContainer: DesignTokens.pinkDarkOnErrorContainer,
    surface: DesignTokens.pinkDarkSurface,
    onSurface: DesignTokens.pinkDarkOnSurface,
    onSurfaceVariant: DesignTokens.pinkDarkOnSurfaceVariant,
    outline: DesignTokens.pinkDarkOutline,
    outlineVariant: DesignTokens.pinkDarkOutlineVariant,
  ).copyWith(
    surfaceContainer: DesignTokens.pinkDarkSurfaceContainer,
    surfaceContainerHigh: DesignTokens.pinkDarkSurfaceContainer,
    surfaceContainerHighest: DesignTokens.pinkDarkSurfaceVariant,
  );
}