import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme Provider for managing theme state across the app
class ThemeProvider extends ChangeNotifier {
  ThemeVariant _currentVariant = ThemeVariant.dark;
  
  ThemeVariant get currentVariant => _currentVariant;
  ThemeData get currentTheme => AppTheme.getTheme(_currentVariant);
  
  /// Set the theme variant
  void setTheme(ThemeVariant variant) {
    if (_currentVariant != variant) {
      _currentVariant = variant;
      notifyListeners();
    }
  }
  
  /// Toggle between light and dark theme
  void toggleLightDark() {
    if (_currentVariant == ThemeVariant.light) {
      setTheme(ThemeVariant.dark);
    } else {
      setTheme(ThemeVariant.light);
    }
  }
  
  /// Check if current theme is dark
  bool get isDark => _currentVariant != ThemeVariant.light;
  
  /// Check if current theme is pink dark variant
  bool get isPinkDark => _currentVariant == ThemeVariant.pinkDark;
  
  /// Get all available theme variants
  List<ThemeVariant> get availableVariants => ThemeVariant.values;
  
  /// Get display name for theme variant
  String getVariantDisplayName(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.light:
        return 'Light';
      case ThemeVariant.dark:
        return 'Dark';
      case ThemeVariant.pinkDark:
        return 'Pink Dark';
    }
  }
}