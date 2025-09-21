import 'package:flutter/material.dart';

enum ScreenSize {
  compact, // < 600dp
  medium, // 600-959dp
  expanded // ≥ 960dp
}

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return ScreenSize.compact;
  if (width < 960) return ScreenSize.medium;
  return ScreenSize.expanded;
}