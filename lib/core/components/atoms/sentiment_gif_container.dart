import 'package:flutter/material.dart';

class SentimentGifContainer extends StatefulWidget {
  final String? gifUrl;
  final double size;
  final double borderRadius;
  final bool showAnimation;
  final VoidCallback? onTap;
  
  const SentimentGifContainer({
    super.key,
    this.gifUrl,
    this.size = 120.0,
    this.borderRadius = 4.0, // Will be overridden by theme
    this.showAnimation = true,
    this.onTap,
  });

  @override
  State<SentimentGifContainer> createState() => _SentimentGifContainerState();
}

class _SentimentGifContainerState extends State<SentimentGifContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SentimentGifContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation != oldWidget.showAnimation) {
      if (widget.showAnimation) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 0;
      }
    }
  }

  Widget _buildPlaceholder() {
    final themeRadius = (Theme.of(context).textButtonTheme.style?.shape?.resolve({}) as RoundedRectangleBorder?)
        ?.borderRadius as BorderRadius?;
    final radius = themeRadius?.topLeft.x ?? 8.0;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.emoji_emotions,
          size: widget.size * 0.4,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeRadius = (Theme.of(context).textButtonTheme.style?.shape?.resolve({}) as RoundedRectangleBorder?)
        ?.borderRadius as BorderRadius?;
    final radius = themeRadius?.topLeft.x ?? 8.0;

    Widget content;
    
    if (widget.gifUrl != null && widget.gifUrl!.isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          widget.gifUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      content = _buildPlaceholder();
    }

    if (widget.showAnimation) {
      content = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: content,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}