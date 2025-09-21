import 'package:flutter/material.dart';
import '../../themes/spacing_theme.dart';

class TemplateQuestionScore extends StatelessWidget {
  final String score;
  final double size;

  const TemplateQuestionScore({
    super.key,
    required this.score,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(context.spacing.xs / 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          score,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
