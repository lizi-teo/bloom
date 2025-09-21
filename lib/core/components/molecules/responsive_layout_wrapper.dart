import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';
import 'material_app_bar.dart';

/// A responsive layout wrapper that handles navigation for web and mobile
/// Uses Row-based layout for desktop with persistent navigation
/// Uses modal drawer for mobile
class ResponsiveLayoutWrapper extends StatelessWidget {
  final String title;
  final String selectedRoute;
  final Widget child;
  final VoidCallback? onAvatarPressed;
  final String? avatarText;
  final VoidCallback? onMenuPressed; // For custom menu button behavior
  final Widget? floatingActionButton;

  const ResponsiveLayoutWrapper({
    super.key,
    required this.title,
    required this.selectedRoute,
    required this.child,
    this.onAvatarPressed,
    this.avatarText,
    this.onMenuPressed,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    final theme = Theme.of(context);
    
    // Debug: Log screen size for troubleshooting
    // print('DEBUG: Screen size: $screenSize, Width: ${MediaQuery.of(context).size.width}');

    // Mobile layout: Use traditional Scaffold with back button
    if (screenSize == ScreenSize.compact) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: MaterialAppBar(
          onMenuPressed: onMenuPressed ?? () => Navigator.of(context).pop(),
          showMenuButton: onMenuPressed != null, // Only show back button when callback is provided
          onAvatarPressed: onAvatarPressed,
          avatarText: avatarText,
        ),
        body: child,
        floatingActionButton: floatingActionButton,
      );
    }

    // Desktop/Tablet layout: Simple scaffold with top app bar and back button
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: MaterialAppBar(
        onMenuPressed: onMenuPressed ?? () => Navigator.of(context).pop(),
        showMenuButton: onMenuPressed != null, // Only show back button when callback is provided
        onAvatarPressed: onAvatarPressed,
        avatarText: avatarText,
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}

