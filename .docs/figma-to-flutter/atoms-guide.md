# Creating Atoms (Small Components)

**You are a Flutter frontend engineer building production-quality atomic components for a scalable design system. Atoms are the smallest reusable UI elements that encapsulate single design decisions and maintain consistency across the application.**

**Priority Order: Material 3 → Existing Atoms → New Atoms (with approval)**

## Before Creating Any Atom

### 1. Check Material 3 Components First
```dart
// Use Flutter SDK Material 3 components:
FilledButton, OutlinedButton, TextButton
Card, Chip, FilterChip
TextField, Switch, Slider
CircularProgressIndicator, LinearProgressIndicator
```

### 2. Check Existing Atoms
Look in `lib/atoms/` and `lib/molecules/` for existing components.

### 3. Only Create New If Absolutely Necessary
Get user approval before creating new atom files.

## Production-Quality Atom Examples

### Example 1: Interactive Icon Button with Accessibility

```dart
// File: lib/atoms/interactive_icon_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:bloom_app/theme/design_tokens.dart';

/// A production-ready icon button that supports selection state, 
/// accessibility features, and consistent theming across the app.
class InteractiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool isSelected;
  final bool isLoading;
  final InteractiveIconButtonSize size;

  const InteractiveIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.isSelected = false,
    this.isLoading = false,
    this.size = InteractiveIconButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isLoading;
    
    return Semantics(
      button: true,
      enabled: isEnabled,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          child: Container(
            width: size.containerSize,
            height: size.containerSize,
            decoration: BoxDecoration(
              color: _getBackgroundColor(colorScheme),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              border: isSelected ? Border.all(
                color: colorScheme.primary,
                width: 2,
              ) : null,
            ),
            child: Center(
              child: isLoading 
                ? SizedBox(
                    width: size.iconSize * 0.8,
                    height: size.iconSize * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _getForegroundColor(colorScheme),
                    ),
                  )
                : Icon(
                    icon,
                    size: size.iconSize,
                    color: _getForegroundColor(colorScheme),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (!_isEnabled) return colorScheme.surfaceVariant.withOpacity(0.38);
    if (isSelected) return colorScheme.primaryContainer;
    return Colors.transparent;
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    if (!_isEnabled) return colorScheme.onSurface.withOpacity(0.38);
    if (isSelected) return colorScheme.onPrimaryContainer;
    return colorScheme.onSurface;
  }

  bool get _isEnabled => onPressed != null && !isLoading;
}

enum InteractiveIconButtonSize {
  small(containerSize: 32.0, iconSize: 16.0),
  medium(containerSize: 48.0, iconSize: 24.0),
  large(containerSize: 56.0, iconSize: 32.0);

  const InteractiveIconButtonSize({
    required this.containerSize,
    required this.iconSize,
  });

  final double containerSize;
  final double iconSize;
}
```

### Example 2: Status Indicator with Animation and Error Handling

```dart
// File: lib/atoms/status_indicator.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:bloom_app/theme/design_tokens.dart';

/// A production-ready status indicator that provides visual feedback
/// with animations, accessibility support, and consistent theming.
class StatusIndicator extends StatefulWidget {
  final StatusType status;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool animated;
  final String? semanticValue;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.label,
    this.icon,
    this.onTap,
    this.animated = true,
    this.semanticValue,
  });

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusConfig = widget.status.getConfig(colorScheme);
    final hasInteraction = widget.onTap != null;

    return Semantics(
      button: hasInteraction,
      label: widget.label,
      value: widget.semanticValue ?? widget.status.accessibilityLabel,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing12,
                    vertical: DesignTokens.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: statusConfig.backgroundColor,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    border: Border.all(
                      color: statusConfig.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 16,
                          color: statusConfig.foregroundColor,
                        ),
                        SizedBox(width: DesignTokens.spacing4),
                      ],
                      if (widget.status == StatusType.loading)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: statusConfig.foregroundColor,
                          ),
                        )
                      else
                        Text(
                          widget.label,
                          style: DesignTokens.labelSmall.copyWith(
                            color: statusConfig.foregroundColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum StatusType {
  success,
  error,
  warning,
  info,
  loading,
  inactive;

  StatusConfig getConfig(ColorScheme colorScheme) {
    switch (this) {
      case StatusType.success:
        return StatusConfig(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          borderColor: colorScheme.primary,
        );
      case StatusType.error:
        return StatusConfig(
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          borderColor: colorScheme.error,
        );
      case StatusType.warning:
        return StatusConfig(
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
          borderColor: colorScheme.tertiary,
        );
      case StatusType.info:
        return StatusConfig(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          borderColor: colorScheme.secondary,
        );
      case StatusType.loading:
        return StatusConfig(
          backgroundColor: colorScheme.surfaceVariant,
          foregroundColor: colorScheme.onSurfaceVariant,
          borderColor: colorScheme.outline,
        );
      case StatusType.inactive:
        return StatusConfig(
          backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
          foregroundColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
          borderColor: colorScheme.outline.withOpacity(0.5),
        );
    }
  }

  String get accessibilityLabel {
    switch (this) {
      case StatusType.success:
        return 'Success status';
      case StatusType.error:
        return 'Error status';
      case StatusType.warning:
        return 'Warning status';
      case StatusType.info:
        return 'Information status';
      case StatusType.loading:
        return 'Loading status';
      case StatusType.inactive:
        return 'Inactive status';
    }
  }
}

class StatusConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const StatusConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}
```

## Production-Quality Atom Principles

### 1. Comprehensive State Management
```dart
// ✅ Production approach - Handle all interaction states
class ProductionAtom extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      opacity: _getOpacity(),
      child: Material(
        child: InkWell(
          onTap: _isInteractive ? onPressed : null,
          child: _buildContent(),
        ),
      ),
    );
  }

  double _getOpacity() {
    if (widget.errorMessage != null) return 0.6;
    if (!_isInteractive) return 0.38;
    return 1.0;
  }

  bool get _isInteractive => widget.onPressed != null && !widget.isLoading;
}

// ❌ Basic approach - Only handles simple states
class BasicAtom extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isEnabled;
  // Missing: loading, error, focus states
}
```

### 2. Accessibility-First Design
```dart
// ✅ Comprehensive accessibility
return Semantics(
  button: widget.onPressed != null,
  enabled: _isInteractive,
  label: widget.semanticLabel,
  value: widget.semanticValue,
  hint: widget.semanticHint,
  excludeSemantics: true,
  child: Focus(
    onFocusChange: _handleFocusChange,
    child: Container(
      constraints: BoxConstraints(
        minWidth: 48,  // WCAG AA touch target
        minHeight: 48,
      ),
      // Implementation...
    ),
  ),
);

// ❌ Missing accessibility considerations
return GestureDetector(
  onTap: onTap,
  child: Container(/* No semantic info, touch targets */),
);
```

### 3. Theme System Integration
```dart
// ✅ Proper theme integration with fallbacks
class ThemeIntegratedAtom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Text(
        widget.text,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ) ?? DesignTokens.labelMedium, // Fallback for null safety
      ),
    );
  }
}

// ❌ Hardcoded values that break theming
Container(
  color: Color(0xFF123456),  // Breaks dark mode
  child: Text(
    text,
    style: TextStyle(fontSize: 14),  // Ignores user preferences
  ),
)
```

### 4. Performance Optimization
```dart
// ✅ Optimized for performance
class OptimizedAtom extends StatelessWidget {
  static const double _borderRadius = 8.0;  // Cache constants
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(  // Isolate repaints
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => _buildAnimatedContent(),
        ),
      ),
    );
  }
  
  // Cache expensive computations
  late final BorderRadius _cachedBorderRadius = 
    BorderRadius.circular(_borderRadius);
}

// ❌ Performance issues
class UnoptimizedAtom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),  // Recreated each build
      ),
      child: CustomPaint(
        painter: ExpensivePainter(),  // No RepaintBoundary
      ),
    );
  }
}
```

## Professional Decision Framework

### 1. Evaluate Existing Solutions First
```dart
// ✅ Leverage Material 3 component ecosystem
final buttons = [
  FilledButton(onPressed: action, child: Text('Primary')),
  OutlinedButton(onPressed: action, child: Text('Secondary')),
  TextButton(onPressed: action, child: Text('Tertiary')),
  SegmentedButton<int>(
    segments: segments,
    selected: {selectedIndex},
    onSelectionChanged: onChanged,
  ),
];

// ❌ Reinventing existing solutions
class CustomPrimaryButton extends StatelessWidget {
  // Duplicates FilledButton functionality
}
```

### 2. Composition Over Custom Components
```dart
// ✅ Compose existing atoms/molecules
class UserProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
        SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: DesignTokens.headlineSmall),
              StatusIndicator(
                status: user.isOnline ? StatusType.success : StatusType.inactive,
                label: user.isOnline ? 'Online' : 'Offline',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ❌ Creating monolithic custom atoms
class CustomUserProfile extends StatelessWidget {
  // Reimplements avatar, text, and status functionality
}
```

### 3. Architecture Considerations
```dart
// ✅ Consider component hierarchy and reusability
abstract class BaseInteractiveAtom extends StatefulWidget {
  // Common interaction patterns for all interactive atoms
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String semanticLabel;
  
  const BaseInteractiveAtom({
    super.key,
    required this.semanticLabel,
    this.onPressed,
    this.isEnabled = true,
  });
}

// Specific implementations extend base functionality
class InteractiveIconButton extends BaseInteractiveAtom {
  final IconData icon;
  final InteractiveIconButtonSize size;
  // Implementation...
}

// ❌ Duplicating common functionality across atoms
class CustomIconButton extends StatelessWidget { /* Full implementation */ }
class CustomTextButton extends StatelessWidget { /* Duplicate logic */ }
```

## Professional File Organization

```
lib/
├── atoms/
│   ├── base/
│   │   ├── base_interactive_atom.dart      // Shared behavior
│   │   └── atom_constants.dart             // Shared constants
│   ├── buttons/
│   │   └── interactive_icon_button.dart
│   ├── indicators/
│   │   └── status_indicator.dart
│   └── inputs/
│       └── validated_text_field.dart
├── molecules/                              // Existing compositions
└── organisms/                              // Complex components
```

## Production Checklist

### Functionality ✓
- [ ] Handles all expected user interactions
- [ ] Provides appropriate feedback for all states
- [ ] Gracefully handles edge cases and errors
- [ ] Integrates with app-wide state management patterns

### Accessibility ✓
- [ ] WCAG AA compliant (minimum 48px touch targets)
- [ ] Screen reader support with semantic labels
- [ ] Keyboard navigation support
- [ ] High contrast mode compatibility
- [ ] Supports user text scaling preferences

### Design System ✓
- [ ] Uses theme colors exclusively (no hardcoded values)
- [ ] Follows Material 3 design principles
- [ ] Consistent with existing component library
- [ ] Responsive across different screen sizes
- [ ] Works in both light and dark themes

### Performance ✓
- [ ] Optimized rendering with RepaintBoundary where needed
- [ ] Efficient animation controllers (proper disposal)
- [ ] Minimal widget rebuilds during interactions
- [ ] Cached expensive computations

### Maintainability ✓
- [ ] Comprehensive documentation with usage examples
- [ ] Unit tests covering all interaction states
- [ ] Integration tests for accessibility features
- [ ] Follows established code patterns and naming conventions