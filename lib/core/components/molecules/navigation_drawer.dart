import 'package:flutter/material.dart';
import '../../../core/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

enum NavigationDrawerMode {
  modal,
  persistent,
}

class NavigationDrawerWidget extends StatelessWidget {
  final NavigationDrawerMode mode;
  final String? selectedRoute;

  const NavigationDrawerWidget({
    super.key,
    this.mode = NavigationDrawerMode.modal,
    this.selectedRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // For modal mode, wrap in SafeArea with bottom sheet styling
    if (mode == NavigationDrawerMode.modal) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar for modal
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Menu header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Menu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const Divider(height: 1),
            
            ..._buildMenuItems(context),
            
            const SizedBox(height: 16.0),
          ],
        ),
      );
    }

    // For persistent mode, use full drawer styling
    return Drawer(
      width: 280,
      child: Column(
        children: [
          // App header in drawer
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Bloom',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Feedback Platform',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: _buildMenuItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem(
        context: context,
        icon: Icons.add_circle_outline,
        title: 'Create Session',
        route: '/session/create',
        onTap: () {
          _navigateAndClose(context, () {
            context.read<NavigationProvider>().navigateTo('/session_create');
          });
        },
      ),
      
      _buildMenuItem(
        context: context,
        icon: Icons.list,
        title: 'Sessions List',
        route: '/sessions',
        onTap: () {
          _navigateAndClose(context, () {
            context.read<NavigationProvider>().navigateTo('/sessions_list');
          });
        },
      ),
      
      _buildMenuItem(
        context: context,
        icon: Icons.view_list,
        title: 'View Templates',
        route: '/templates',
        onTap: () {
          _navigateAndClose(context, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Templates page coming soon!'),
              ),
            );
          });
        },
      ),
    ];
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedRoute == route;
    
    if (mode == NavigationDrawerMode.modal) {
      // Modal style - simple list tile
      return ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        onTap: onTap,
      );
    }
    
    // Persistent drawer style - Material 3 navigation drawer item
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateAndClose(BuildContext context, VoidCallback navigate) {
    // Close modal if in modal mode
    if (mode == NavigationDrawerMode.modal) {
      Navigator.pop(context);
    }
    // Close persistent drawer if open
    else if (Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context);
    }
    
    navigate();
  }
}