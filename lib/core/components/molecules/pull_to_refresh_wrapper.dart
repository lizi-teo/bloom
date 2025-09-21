import 'package:flutter/material.dart';

class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshMessage;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage,
    this.color,
    this.padding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    final theme = Theme.of(context);
    final refreshColor = color ?? theme.colorScheme.primary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshColor,
      backgroundColor: theme.colorScheme.surface,
      strokeWidth: 2.5,
      displacement: 40.0,
      edgeOffset: padding?.resolve(TextDirection.ltr).top ?? 0,
      child: child,
    );
  }
}

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshMessage;
  final Widget? refreshIcon;
  final Duration animationDuration;
  final Curve animationCurve;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage,
    this.refreshIcon,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    _rotationController.repeat();
    _scaleController.forward();
    
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _rotationController.stop();
        _scaleController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isRefreshing = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: widget.refreshIcon ?? 
                               Icon(
                                 Icons.refresh,
                                 color: Theme.of(context).colorScheme.primary,
                                 size: 32,
                               ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SmartRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback? onEndReached;
  final String? refreshMessage;
  final String? loadingMessage;
  final bool canRefresh;
  final bool canLoadMore;
  final double endReachedThreshold;

  const SmartRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onEndReached,
    this.refreshMessage,
    this.loadingMessage,
    this.canRefresh = true,
    this.canLoadMore = false,
    this.endReachedThreshold = 200.0,
  });

  @override
  State<SmartRefreshWrapper> createState() => _SmartRefreshWrapperState();
}

class _SmartRefreshWrapperState extends State<SmartRefreshWrapper> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.canLoadMore && widget.onEndReached != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.canLoadMore || widget.onEndReached == null || _isLoadingMore) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (maxScrollExtent - currentScroll <= widget.endReachedThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      widget.onEndReached?.call();
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    
    if (widget.canLoadMore) {
      content = Column(
        children: [
          Expanded(child: content),
          if (_isLoadingMore)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    widget.loadingMessage ?? 'Loading more...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    if (widget.canRefresh) {
      content = PullToRefreshWrapper(
        onRefresh: widget.onRefresh,
        refreshMessage: widget.refreshMessage,
        child: content,
      );
    }

    return content;
  }
}

class RefreshableList<T> extends StatefulWidget {
  final Future<List<T>> Function() loadData;
  final Widget Function(BuildContext context, List<T> items) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Duration refreshDelay;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;
  final String? refreshMessage;
  
  const RefreshableList({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.refreshDelay = const Duration(milliseconds: 500),
    this.enablePullToRefresh = true,
    this.enableInfiniteScroll = false,
    this.refreshMessage,
  });

  @override
  State<RefreshableList<T>> createState() => _RefreshableListState<T>();
}

class _RefreshableListState<T> extends State<RefreshableList<T>> {
  List<T>? _data;
  Object? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(widget.refreshDelay);
      final data = await widget.loadData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _data == null) {
      return widget.loadingBuilder?.call(context) ?? 
             const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, _refresh) ??
             Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.error, size: 48, color: Colors.red),
                   const SizedBox(height: 16),
                   Text('Error: $_error'),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: _refresh,
                     child: const Text('Retry'),
                   ),
                 ],
               ),
             );
    }

    if (_data?.isEmpty ?? true) {
      return widget.emptyBuilder?.call(context) ??
             const Center(
               child: Text('No items found'),
             );
    }

    Widget content = widget.itemBuilder(context, _data!);

    if (widget.enablePullToRefresh) {
      content = PullToRefreshWrapper(
        onRefresh: _refresh,
        refreshMessage: widget.refreshMessage,
        child: content,
      );
    }

    return content;
  }
}