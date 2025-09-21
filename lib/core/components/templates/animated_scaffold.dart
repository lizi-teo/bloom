import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../molecules/animated_sliver_app_bar.dart';

/// A scaffold wrapper that provides Material Design 3 scroll animations
/// Combines Scaffold with NestedScrollView for smooth app bar animations
class AnimatedScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  
  // App bar specific properties
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;
  final double collapsedHeight;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;
  final String? avatarText;
  final Color? appBarBackgroundColor;
  final Color? surfaceTintColor;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double scrolledUnderElevation;
  final bool showAvatar;
  final bool animateTitle;
  final bool animateAvatar;
  final bool animateMenuIcon;
  final Duration animationDuration;
  final bool useSafeArea;
  
  // Scroll view properties
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool reverse;
  
  const AnimatedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.pinned = false,
    this.floating = true,
    this.snap = true,
    this.expandedHeight = 64.0,
    this.collapsedHeight = 64.0,
    this.onMenuPressed,
    this.onAvatarPressed,
    this.avatarText,
    this.appBarBackgroundColor,
    this.surfaceTintColor,
    this.flexibleSpace,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.scrolledUnderElevation = 3.0,
    this.showAvatar = true,
    this.animateTitle = true,
    this.animateAvatar = true,
    this.animateMenuIcon = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.useSafeArea = false,
    this.scrollController,
    this.physics,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Build the drawer with proper menu button integration
    Widget? effectiveDrawer = drawer;
    VoidCallback? effectiveOnMenuPressed = onMenuPressed;
    
    if (drawer != null && onMenuPressed == null) {
      effectiveOnMenuPressed = () {
        Scaffold.of(context).openDrawer();
      };
    }
    
    Widget bodyContent = ScrollNotificationObserver(
      child: NestedScrollView(
        controller: scrollController,
        physics: physics,
        reverse: reverse,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            AnimatedSliverAppBar(
              title: title,
              pinned: pinned,
              floating: floating,
              snap: snap,
              expandedHeight: expandedHeight,
              collapsedHeight: collapsedHeight,
              onMenuPressed: effectiveOnMenuPressed,
              onAvatarPressed: onAvatarPressed,
              avatarText: avatarText,
              backgroundColor: appBarBackgroundColor,
              surfaceTintColor: surfaceTintColor,
              flexibleSpace: flexibleSpace,
              actions: actions,
              leading: leading,
              centerTitle: centerTitle,
              scrolledUnderElevation: scrolledUnderElevation,
              showAvatar: showAvatar,
              animateTitle: animateTitle,
              animateAvatar: animateAvatar,
              animateMenuIcon: animateMenuIcon,
              animationDuration: animationDuration,
            ),
          ];
        },
        body: body,
      ),
    );
    
    if (useSafeArea) {
      bodyContent = SafeArea(child: bodyContent);
    }
    
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      drawer: effectiveDrawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      body: bodyContent,
    );
  }
}

/// A simpler version for pages that already use CustomScrollView
class AnimatedSliverScaffold extends StatelessWidget {
  final List<Widget> slivers;
  final String title;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  
  // App bar specific properties
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;
  final double collapsedHeight;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;
  final String? avatarText;
  final Color? appBarBackgroundColor;
  final Color? surfaceTintColor;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double scrolledUnderElevation;
  final bool showAvatar;
  final bool animateTitle;
  final bool animateAvatar;
  final bool animateMenuIcon;
  final Duration animationDuration;
  final bool useSafeArea;
  
  // Scroll view properties
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool reverse;
  
  const AnimatedSliverScaffold({
    super.key,
    required this.slivers,
    required this.title,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.pinned = false,
    this.floating = true,
    this.snap = true,
    this.expandedHeight = 64.0,
    this.collapsedHeight = 64.0,
    this.onMenuPressed,
    this.onAvatarPressed,
    this.avatarText,
    this.appBarBackgroundColor,
    this.surfaceTintColor,
    this.flexibleSpace,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.scrolledUnderElevation = 3.0,
    this.showAvatar = true,
    this.animateTitle = true,
    this.animateAvatar = true,
    this.animateMenuIcon = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.useSafeArea = false,
    this.scrollController,
    this.physics,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Build the drawer with proper menu button integration
    Widget? effectiveDrawer = drawer;
    VoidCallback? effectiveOnMenuPressed = onMenuPressed;
    
    if (drawer != null && onMenuPressed == null) {
      effectiveOnMenuPressed = () {
        Scaffold.of(context).openDrawer();
      };
    }
    
    Widget bodyContent = ScrollNotificationObserver(
      child: CustomScrollView(
        controller: scrollController,
        physics: physics,
        reverse: reverse,
        slivers: [
          AnimatedSliverAppBar(
            title: title,
            pinned: pinned,
            floating: floating,
            snap: snap,
            expandedHeight: expandedHeight,
            collapsedHeight: collapsedHeight,
            onMenuPressed: effectiveOnMenuPressed,
            onAvatarPressed: onAvatarPressed,
            avatarText: avatarText,
            backgroundColor: appBarBackgroundColor,
            surfaceTintColor: surfaceTintColor,
            flexibleSpace: flexibleSpace,
            actions: actions,
            leading: leading,
            centerTitle: centerTitle,
            scrolledUnderElevation: scrolledUnderElevation,
            showAvatar: showAvatar,
            animateTitle: animateTitle,
            animateAvatar: animateAvatar,
            animateMenuIcon: animateMenuIcon,
            animationDuration: animationDuration,
          ),
          ...slivers,
        ],
      ),
    );
    
    if (useSafeArea) {
      bodyContent = SafeArea(child: bodyContent);
    }
    
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      drawer: effectiveDrawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: bodyContent,
    );
  }
}