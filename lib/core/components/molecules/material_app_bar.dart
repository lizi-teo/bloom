import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive_utils.dart';

/// Material Design 3 compliant app bar component
/// Features: Proper MD3 sizing, scrolling behavior, animation support
class MaterialAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;
  final String? avatarText;
  final Color? backgroundColor;
  final bool showMenuButton;
  final bool isBackButton; // Indicates if this should show back arrow vs hamburger
  final bool centerTitle;
  final double? elevation;
  final bool floating;
  final bool pinned;
  final bool snap;
  final Widget? flexibleSpace;
  final List<Widget>? actions;

  const MaterialAppBar({
    super.key,
    this.title,
    this.onMenuPressed,
    this.onAvatarPressed,
    this.avatarText,
    this.backgroundColor,
    this.showMenuButton = true,
    this.isBackButton = false,
    this.centerTitle = true,
    this.elevation,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.flexibleSpace,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 3.0, // Material Design 3 standard
      toolbarHeight: _getAppBarHeight(screenSize),
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: title != null ? _buildTitle(context) : null,
      actions: _buildActions(context),
      flexibleSpace: flexibleSpace,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // Always show back arrow when showMenuButton is true
    if (!showMenuButton || !_isCurrentUserFacilitator()) {
      return null;
    }

    final theme = Theme.of(context);
    const iconSize = 24.0; // Material Design 3 standard

    // Always show back arrow, use custom onPressed or default back navigation
    final onPressed = onMenuPressed ?? () => Navigator.of(context).pop();

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.arrow_back,
        size: iconSize,
        color: theme.colorScheme.onSurface,
      ),
      style: IconButton.styleFrom(
        minimumSize: const Size(48.0, 48.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  bool _isCurrentUserFacilitator() {
    final authService = AuthService();
    return authService.isAuthenticated;
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title ?? '',
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionsList = [];
    
    // Add custom actions if provided
    if (actions != null) {
      actionsList.addAll(actions!);
    }

    // Add avatar
    actionsList.add(_buildAvatar(context));
    
    return actionsList;
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    const avatarSize = 40.0; // Material Design 3 standard
    final displayText = avatarText?.isNotEmpty == true 
        ? avatarText!.substring(0, 1).toUpperCase() 
        : 'U';

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(48.0 / 2),
        child: InkWell(
          onTap: onAvatarPressed ?? () => _showUserMenu(context),
          borderRadius: BorderRadius.circular(48.0 / 2),
          child: Container(
            width: 48.0,
            height: 48.0,
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                displayText,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    final authService = AuthService();
    final userEmail = authService.getUserEmail();
    final isDemoUser = userEmail == 'lizzie.tls@gmail.com';
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        kToolbarHeight,
        0,
        0,
      ),
      items: [
        if (isDemoUser)
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.science),
              title: Text('Demo Mode'),
              contentPadding: EdgeInsets.zero,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Demo mode activated!'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () async {
            try {
              await authService.signOut();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  double _getAppBarHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 56.0; // Material Design 3 mobile standard
      case ScreenSize.medium:
      case ScreenSize.expanded:
        return 64.0; // Material Design 3 tablet/desktop standard
    }
  }


  @override
  Size get preferredSize => Size.fromHeight(_getAppBarHeight(ScreenSize.compact));
}

/// Material Design 3 Sliver App Bar with scroll animations
/// Use this for scrollable content with hide/show animations
class MaterialSliverAppBar extends StatelessWidget {
  final String? title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;
  final String? avatarText;
  final Color? backgroundColor;
  final bool showMenuButton;
  final bool isBackButton; // Indicates if this should show back arrow vs hamburger
  final bool centerTitle;
  final bool floating;
  final bool pinned;
  final bool snap;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final List<Widget>? actions;

  const MaterialSliverAppBar({
    super.key,
    this.title,
    this.onMenuPressed,
    this.onAvatarPressed,
    this.avatarText,
    this.backgroundColor,
    this.showMenuButton = true,
    this.isBackButton = false,
    this.centerTitle = true,
    this.floating = true,
    this.pinned = false,
    this.snap = true,
    this.expandedHeight = 64.0,
    this.flexibleSpace,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      scrolledUnderElevation: 3.0,
      floating: floating,
      pinned: pinned,
      snap: snap,
      expandedHeight: expandedHeight,
      toolbarHeight: 64.0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: title != null ? _buildTitle(context) : null,
      actions: _buildActions(context),
      flexibleSpace: flexibleSpace,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!showMenuButton || !_isCurrentUserFacilitator()) {
      return null;
    }

    final theme = Theme.of(context);
    const iconSize = 24.0;

    // Always show back arrow, use custom onPressed or default back navigation
    final onPressed = onMenuPressed ?? () => Navigator.of(context).pop();

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.arrow_back,
        size: iconSize,
        color: theme.colorScheme.onSurface,
      ),
      style: IconButton.styleFrom(
        minimumSize: const Size(48.0, 48.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  bool _isCurrentUserFacilitator() {
    final authService = AuthService();
    return authService.isAuthenticated;
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title ?? '',
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionsList = [];
    
    if (actions != null) {
      actionsList.addAll(actions!);
    }

    actionsList.add(_buildAvatar(context));
    
    return actionsList;
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    const avatarSize = 40.0;
    final displayText = avatarText?.isNotEmpty == true 
        ? avatarText!.substring(0, 1).toUpperCase() 
        : 'U';

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(48.0 / 2),
        child: InkWell(
          onTap: onAvatarPressed ?? () => _showSliverUserMenu(context),
          borderRadius: BorderRadius.circular(48.0 / 2),
          child: Container(
            width: 48.0,
            height: 48.0,
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                displayText,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSliverUserMenu(BuildContext context) {
    final authService = AuthService();
    final userEmail = authService.getUserEmail();
    final isDemoUser = userEmail == 'lizzie.tls@gmail.com';
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        kToolbarHeight,
        0,
        0,
      ),
      items: [
        if (isDemoUser)
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.science),
              title: Text('Demo Mode'),
              contentPadding: EdgeInsets.zero,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Demo mode activated!'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () async {
            try {
              await authService.signOut();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

}