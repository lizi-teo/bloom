import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';
import '../../themes/spacing_theme.dart';

class SliderCard extends StatefulWidget {
  final String questionTitle;
  final String questionName;
  final String minLabel;
  final String maxLabel;
  final int value;
  final ValueChanged<int> onChanged;
  final ValueChanged<int>? onChangeEnd;
  final int min;
  final int max;

  const SliderCard({
    super.key,
    required this.questionTitle,
    required this.questionName,
    required this.minLabel,
    required this.maxLabel,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
  });

  @override
  State<SliderCard> createState() => _SliderCardState();
}

class _SliderCardState extends State<SliderCard> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
  }

  @override
  void didUpdateWidget(SliderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
    }
  }

  void _handleValueChange(double value) {
    final intValue = value.round().clamp(widget.min, widget.max);
    if (intValue != _currentValue) {
      setState(() {
        _currentValue = intValue;
      });
      widget.onChanged(intValue);
    }
  }

  void _handleChangeStart(double value) {
    // Start interaction
  }

  void _handleChangeEnd(double value) {
    final intValue = value.round().clamp(widget.min, widget.max);
    widget.onChangeEnd?.call(intValue);
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
            style: theme.textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
          SizedBox(height: context.spacing.xl),

          // Slider Section
          Column(
            children: [
              // Slider with inline value
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: '${widget.questionTitle} slider',
                      value: '$_currentValue percent',
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor: colorScheme.secondaryContainer,
                          thumbColor: colorScheme.primary,
                          overlayColor: colorScheme.primary.withValues(alpha: 0.1),
                          valueIndicatorColor: colorScheme.inverseSurface,
                          valueIndicatorTextStyle: TextStyle(
                            color: colorScheme.onInverseSurface,
                          ),
                          showValueIndicator: ShowValueIndicator.onlyForDiscrete,
                        ),
                        child: Slider(
                          value: _currentValue.toDouble(),
                          min: widget.min.toDouble(),
                          max: widget.max.toDouble(),
                          divisions: widget.max - widget.min,
                          label: '$_currentValue',
                          onChanged: _handleValueChange,
                          onChangeStart: _handleChangeStart,
                          onChangeEnd: _handleChangeEnd,
                          semanticFormatterCallback: (value) => '${value.round()} percent',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing.md),

                  // Inline value display
                  Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    child: Text(
                      '$_currentValue%',
                      style: theme.textTheme.titleSmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.lg),

              // Min/Max labels
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Min label
                    Flexible(
                      child: Text(
                        widget.minLabel,
                        style: theme.textTheme.titleSmall!.copyWith(
                              color: colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.start,
                      ),
                    ),

                    // Max label
                    Flexible(
                      child: Text(
                        widget.maxLabel,
                        style: theme.textTheme.titleSmall!.copyWith(
                              color: colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
