import 'package:flutter/material.dart';
import '../../themes/spacing_theme.dart';

abstract class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  String get title;
  String get route;

  Widget? get floatingActionButton => null;
  bool get showAppBar => true;

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ContentContainer(
      title: title,
      showAppBar: showAppBar,
      floatingActionButton: floatingActionButton,
      child: buildContent(context),
    );
  }
}

class ContentContainer extends StatelessWidget {
  final String title;
  final bool showAppBar;
  final Widget? floatingActionButton;
  final Widget child;

  const ContentContainer({
    super.key,
    required this.title,
    required this.child,
    this.showAppBar = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
            )
          : null,
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
    );
  }
}

class ContentLoadingState extends StatelessWidget {
  final String message;

  const ContentLoadingState({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: context.spacing.lg),
          Text(message),
        ],
      ),
    );
  }
}

class ContentErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ContentErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: context.spacing.lg),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            SizedBox(height: context.spacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class ContentEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;
  final IconData? icon;

  const ContentEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon!,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          SizedBox(height: context.spacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (action != null) ...[
            SizedBox(height: context.spacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}