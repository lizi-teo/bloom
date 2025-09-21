import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../components/molecules/responsive_layout_wrapper.dart';
import '../services/auth_service.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        final currentRoute = navigationProvider.currentRoute;
        
        String title = _getTitleForRoute(currentRoute);
        VoidCallback? onMenuPressed = _getBackButtonCallback(currentRoute, navigationProvider);
        
        // Get current user's email for avatar
        final authService = AuthService();
        final userEmail = authService.getUserEmail();
        final avatarText = userEmail?.isNotEmpty == true 
            ? userEmail!.substring(0, 1).toUpperCase() 
            : null;
        
        return ResponsiveLayoutWrapper(
          title: title,
          selectedRoute: currentRoute,
          onMenuPressed: onMenuPressed,
          avatarText: avatarText,
          onAvatarPressed: () => _onAvatarPressed(context, userEmail),
          child: navigationProvider.buildContent(context),
        );
      },
    );
  }

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/session_create':
        return 'Create Session';
      case '/sessions_list':
      case '/sessions':
        return 'Bloom';
      case '/qr_code':
        return 'QR Code';
      case '/results':
        return 'Results';
      default:
        return 'Bloom'; // Default to Bloom since that's our landing page
    }
  }

  VoidCallback? _getBackButtonCallback(String route, NavigationProvider navigationProvider) {
    switch (route) {
      case '/session_create':
        // Show back button for create session page that goes to sessions list
        return () => navigationProvider.navigateTo('/sessions_list');
      case '/qr_code':
      case '/results':
        // Show back button for QR code and results pages
        return () => navigationProvider.goBack();
      default:
        // No back button for main navigation pages (sessions list)
        return null;
    }
  }

  void _onAvatarPressed(BuildContext context, String? userEmail) {
    // Show user menu for all users
    _showUserMenu(context);
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final authService = AuthService();
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}