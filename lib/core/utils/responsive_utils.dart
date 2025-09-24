import 'package:flutter/material.dart';

enum ScreenSize {
  compact, // < 600dp
  medium, // 600-959dp
  expanded // ≥ 960dp
}

/// Common Android device widths for testing
enum AndroidDeviceWidth {
  small360, // Budget Android phones (Galaxy A-series) - 360dp
  pixel393, // Pixel 6-8 - 393dp
  samsung412, // Galaxy S21-S24 - 412dp
  tablet600, // Small tablets - 600dp
  desktop960, // Desktop/large tablet - 960dp+
}

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return ScreenSize.compact;
  if (width < 960) return ScreenSize.medium;
  return ScreenSize.expanded;
}

/// Get Android device category for testing purposes
AndroidDeviceWidth getAndroidDeviceWidth(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width <= 360) return AndroidDeviceWidth.small360;
  if (width <= 393) return AndroidDeviceWidth.pixel393;
  if (width <= 412) return AndroidDeviceWidth.samsung412;
  if (width <= 600) return AndroidDeviceWidth.tablet600;
  return AndroidDeviceWidth.desktop960;
}

/// Check if device is likely a budget Android phone
bool isLikelyBudgetAndroid(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width <= 360;
}