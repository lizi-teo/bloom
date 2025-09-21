import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  final bool showSkeleton;
  final Widget? child;

  const LoadingState({
    super.key,
    this.message,
    this.showSkeleton = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (showSkeleton && child != null) {
      return child!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 16.0),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String? retryButtonText;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.retryButtonText,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: 8.0),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: 24.0),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionButtonText,
    this.onActionPressed,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.0),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 24.0),
            if (customAction != null) 
              customAction!
            else if (onActionPressed != null && actionButtonText != null)
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionButtonText!),
              ),
          ],
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const SkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const SkeletonCard({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 80,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

class AsyncBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final String? loadingMessage;

  const AsyncBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? 
                 LoadingState(message: loadingMessage);
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(
            context, 
            snapshot.error!, 
            () => (context as Element).markNeedsBuild(),
          ) ?? ErrorState(
            title: 'Something went wrong',
            message: snapshot.error.toString(),
            onRetry: () => (context as Element).markNeedsBuild(),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return builder(context, snapshot.data as T);
        }

        return const SizedBox.shrink();
      },
    );
  }
}