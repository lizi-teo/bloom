import 'package:flutter/material.dart';
import '../../../features/sessions/models/question.dart';
import '../../utils/responsive_utils.dart';
import '../../themes/spacing_theme.dart';

class TextFieldCard extends StatefulWidget {
  final String questionTitle;
  final String questionName;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  const TextFieldCard({
    super.key,
    required this.questionTitle,
    required this.questionName,
    required this.onChanged,
    this.initialValue,
    this.onSubmitted,
    this.hintText,
    this.maxLines = 3,
    this.maxLength,
    this.keyboardType = TextInputType.multiline,
  });

  /// Create a TextFieldCard from a Question model
  factory TextFieldCard.fromQuestion({
    required Question question,
    required ValueChanged<String> onChanged,
    String? initialValue,
    ValueChanged<String>? onSubmitted,
    String? hintText,
    int? maxLines = 3,
    int? maxLength,
    TextInputType keyboardType = TextInputType.multiline,
  }) {
    return TextFieldCard(
      questionTitle: question.title ?? 'Question',
      questionName: question.question ?? '',
      onChanged: onChanged,
      initialValue: initialValue,
      onSubmitted: onSubmitted,
      hintText: hintText ?? 'Enter your response...',
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
    );
  }

  @override
  State<TextFieldCard> createState() => _TextFieldCardState();
}

class _TextFieldCardState extends State<TextFieldCard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isUpdatingFromWidget = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        // Focus state changed
      });
    });

    _controller.addListener(() {
      if (!_isUpdatingFromWidget) {
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(TextFieldCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _isUpdatingFromWidget = true;
      _controller.text = widget.initialValue ?? '';
      _isUpdatingFromWidget = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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

  // Helper method for responsive card padding
  EdgeInsets _getCardPadding(ScreenSize screenSize, BuildContext context) {
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.all(context.spacing.lg); // 16dp
      case ScreenSize.medium:
        return EdgeInsets.all(context.spacing.xl); // 24dp
      case ScreenSize.expanded:
        return EdgeInsets.all(context.spacing.xxl); // 32dp
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
        borderRadius: BorderRadius.circular(20.0), // 20dp as per spec
      ),
      padding: _getCardPadding(screenSize, context), // Responsive padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Title
          Text(
            widget.questionTitle,
            style: _getTitleStyle(screenSize, theme, colorScheme),
          ),
          SizedBox(height: context.spacing.xl),

          // Question Name (secondary label)
          Text(
            widget.questionName,
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ) ??
                theme.textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
          SizedBox(height: context.spacing.lgPlus), // 20dp spacing

          // Material Design 3 TextField
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: TextInputAction.newline,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onSubmitted: widget.onSubmitted,
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Increased for better mobile touch
                borderSide: BorderSide(
                  color: colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.spacing.lg,
                vertical: context.spacing.lgPlus, // Increased vertical padding for mobile
              ),
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
