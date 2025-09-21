import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../themes/spacing_theme.dart';

class MobileNavigationMenu extends StatelessWidget {
  const MobileNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 32,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(context.spacing.xs / 2),
            ),
          ),
          
          // Menu header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.spacing.lg),
            child: Text(
              'Menu',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // Navigation items with consistent styling
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.lg),
            child: Column(
              children: [
                SizedBox(height: context.spacing.sm),
                
                
                // Create Session
                _buildNavigationItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  selectedIcon: Icons.add_circle,
                  label: 'Create Session',
                  route: '/session_create',
                  isSelected: _isCurrentRoute(context, '/session_create'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<NavigationProvider>().navigateTo('/session_create');
                  },
                ),
                
                // Sessions List  
                _buildNavigationItem(
                  context: context,
                  icon: Icons.sentiment_very_satisfied_outlined,
                  selectedIcon: Icons.sentiment_very_satisfied,
                  label: 'Sessions',
                  route: '/sessions_list',
                  isSelected: _isCurrentRoute(context, '/sessions_list'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<NavigationProvider>().navigateTo('/sessions_list');
                  },
                ),
                
              ],
            ),
          ),
          
          SizedBox(height: context.spacing.lg),
        ],
      ),
    );
  }

  bool _isCurrentRoute(BuildContext context, String route) {
    return context.read<NavigationProvider>().currentRoute == route;
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String route,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.spacing.xs),
      child: Material(
        color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(context.spacing.xl + context.spacing.xs),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.spacing.xl + context.spacing.xs),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(context.spacing.lg),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24.0,
                  color: isSelected 
                    ? colorScheme.onSecondaryContainer 
                    : colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: context.spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected 
                        ? colorScheme.onSecondaryContainer 
                        : colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}