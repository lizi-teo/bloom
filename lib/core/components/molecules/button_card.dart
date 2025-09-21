import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

class ButtonCard extends StatefulWidget {
  final String questionTitle;
  final String questionName;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onChanged;

  const ButtonCard({
    super.key,
    required this.questionTitle,
    required this.questionName,
    required this.options,
    required this.onChanged,
    this.selectedOption,
  });

  @override
  State<ButtonCard> createState() => _ButtonCardState();
}

class _ButtonCardState extends State<ButtonCard> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
  }

  @override
  void didUpdateWidget(ButtonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOption != widget.selectedOption) {
      _selectedOption = widget.selectedOption;
    }
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
    widget.onChanged(option);
  }

  // Helper method for responsive title styling
  TextStyle _getTitleStyle(ScreenSize screenSize, ThemeData theme, ColorScheme colorScheme) {
    switch (screenSize) {
      case ScreenSize.compact:
        return theme.textTheme.headlineSmall!.copyWith(
          color: colorScheme.onSurface,
        );
      case ScreenSize.medium:
        return theme.textTheme.headlineMedium!.copyWith(
          color: colorScheme.onSurface,
        );
      case ScreenSize.expanded:
        return theme.textTheme.headlineLarge!.copyWith(
          color: colorScheme.onSurface,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 240,
        minHeight: 48,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20.0), // 20dp as per Figma Corner/Large-increased
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0), // 24dp card padding as per Figma
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Title
          Text(
            widget.questionTitle,
            style: _getTitleStyle(screenSize, theme, colorScheme),
          ),
          const SizedBox(height: 24.0),

          // Question Name (secondary label)
          Text(
            widget.questionName,
            style: theme.textTheme.bodyLarge?.copyWith(
                  
                  fontSize: 16,
                  
                  color: colorScheme.onSurface,
                  letterSpacing: 0.5,
                  height: 24 / 16,
                ) ??
                theme.textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 24.0),

          // Button Options
          ...widget.options.map((option) {
            final isSelected = _selectedOption == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // 16px spacing between buttons
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: isSelected
                      ? BoxDecoration(
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        )
                      : null,
                  child: FilledButton(
                    onPressed: () => _selectOption(option),
                    style: FilledButton.styleFrom(
                      backgroundColor: isSelected ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHigh,
                      foregroundColor: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    ),
                    child: Text(
                      option,
                      style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 16,
                            letterSpacing: 0.15,
                            height: 24 / 16,
                          ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
