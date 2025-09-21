import 'package:flutter/material.dart';
import '../../themes/spacing_theme.dart';

class SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;

  const SuggestionChip({
    super.key,
    required this.label,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(context.spacing.sm),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.lg,
            vertical: context.spacing.xs + context.spacing.xs / 2,
          ),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(context.spacing.sm),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge!.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
