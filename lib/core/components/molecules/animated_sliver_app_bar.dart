import 'package:flutter/material.dart';

/// Material Design 3 compliant animated sliver app bar
/// Features smooth fade and scale animations based on scroll position
class AnimatedSliverAppBar extends StatelessWidget {
  final String title;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;
  final double collapsedHeight;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;
  final String? avatarText;
  final Color? backgroundColor;
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
  
  const AnimatedSliverAppBar({
    super.key,
    required this.title,
    this.pinned = false,
    this.floating = true,
    this.snap = true,
    this.expandedHeight = 64.0,
    this.collapsedHeight = 64.0,
    this.onMenuPressed,
    this.onAvatarPressed,
    this.avatarText,
    this.backgroundColor,
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayText = avatarText?.isNotEmpty == true 
        ? avatarText!.substring(0, 1).toUpperCase()
        : 'U';
    
    return SliverAppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      surfaceTintColor: surfaceTintColor ?? colorScheme.surfaceTint,
      scrolledUnderElevation: scrolledUnderElevation,
      floating: floating,
      snap: snap,
      pinned: pinned,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      toolbarHeight: collapsedHeight,
      title: animateTitle ? _AnimatedTitle(
        title: title,
        duration: animationDuration,
        textStyle: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
      ) : Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading ?? _buildAnimatedLeading(context, colorScheme),
      actions: _buildActions(context, colorScheme, displayText),
      flexibleSpace: flexibleSpace,
    );
  }
  
  Widget? _buildAnimatedLeading(BuildContext context, ColorScheme colorScheme) {
    if (onMenuPressed == null) return null;
    
    final menuWidget = IconButton(
      icon: Icon(Icons.menu, color: colorScheme.onSurface),
      onPressed: onMenuPressed,
    );
    
    if (!animateMenuIcon) return menuWidget;
    
    return Builder(
      builder: (context) => IconButton(
        icon: _AnimatedMenuIcon(
          color: colorScheme.onSurface,
          duration: animationDuration,
        ),
        onPressed: () {
          if (onMenuPressed != null) {
            onMenuPressed!();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      ),
    );
  }
  
  List<Widget>? _buildActions(BuildContext context, ColorScheme colorScheme, String displayText) {
    final List<Widget> actionsList = [];
    
    if (actions != null) {
      actionsList.addAll(actions!);
    }
    
    if (showAvatar) {
      final avatarWidget = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
          onTap: onAvatarPressed,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary,
            child: Text(
              displayText,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
      
      if (animateAvatar) {
        actionsList.add(
          _AnimatedAvatar(
            avatarWidget: avatarWidget,
            duration: animationDuration,
          ),
        );
      } else {
        actionsList.add(avatarWidget);
      }
    }
    
    return actionsList.isEmpty ? null : actionsList;
  }
}

/// Animated title widget that fades and scales based on scroll
class _AnimatedTitle extends StatefulWidget {
  final String title;
  final Duration duration;
  final TextStyle? textStyle;
  
  const _AnimatedTitle({
    required this.title,
    required this.duration,
    this.textStyle,
  });
  
  @override
  State<_AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<_AnimatedTitle> {
  ScrollNotificationObserverState? _scrollNotificationObserver;
  bool _isScrolledUnder = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
    _scrollNotificationObserver?.addListener(_handleScrollNotification);
  }
  
  @override
  void dispose() {
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    super.dispose();
  }
  
  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && mounted) {
      final isScrolledUnder = notification.metrics.pixels > 0;
      if (_isScrolledUnder != isScrolledUnder) {
        setState(() {
          _isScrolledUnder = isScrolledUnder;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: _isScrolledUnder ? 0.0 : 1.0,
      child: AnimatedScale(
        duration: widget.duration,
        scale: _isScrolledUnder ? 0.8 : 1.0,
        child: Text(
          widget.title,
          style: widget.textStyle,
        ),
      ),
    );
  }
}

/// Animated menu icon that changes based on scroll
class _AnimatedMenuIcon extends StatefulWidget {
  final Color color;
  final Duration duration;
  
  const _AnimatedMenuIcon({
    required this.color,
    required this.duration,
  });
  
  @override
  State<_AnimatedMenuIcon> createState() => _AnimatedMenuIconState();
}

class _AnimatedMenuIconState extends State<_AnimatedMenuIcon> {
  ScrollNotificationObserverState? _scrollNotificationObserver;
  bool _isScrolledUnder = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
    _scrollNotificationObserver?.addListener(_handleScrollNotification);
  }
  
  @override
  void dispose() {
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    super.dispose();
  }
  
  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && mounted) {
      final isScrolledUnder = notification.metrics.pixels > 0;
      if (_isScrolledUnder != isScrolledUnder) {
        setState(() {
          _isScrolledUnder = isScrolledUnder;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      child: Icon(
        _isScrolledUnder ? Icons.menu_open : Icons.menu,
        key: ValueKey(_isScrolledUnder),
        color: widget.color,
      ),
    );
  }
}

/// Animated avatar that fades and scales based on scroll
class _AnimatedAvatar extends StatefulWidget {
  final Widget avatarWidget;
  final Duration duration;
  
  const _AnimatedAvatar({
    required this.avatarWidget,
    required this.duration,
  });
  
  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar> {
  ScrollNotificationObserverState? _scrollNotificationObserver;
  bool _isScrolledUnder = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
    _scrollNotificationObserver?.addListener(_handleScrollNotification);
  }
  
  @override
  void dispose() {
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    super.dispose();
  }
  
  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && mounted) {
      final isScrolledUnder = notification.metrics.pixels > 0;
      if (_isScrolledUnder != isScrolledUnder) {
        setState(() {
          _isScrolledUnder = isScrolledUnder;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: _isScrolledUnder ? 0.3 : 1.0,
      child: AnimatedScale(
        duration: widget.duration,
        scale: _isScrolledUnder ? 0.8 : 1.0,
        child: widget.avatarWidget,
      ),
    );
  }
}