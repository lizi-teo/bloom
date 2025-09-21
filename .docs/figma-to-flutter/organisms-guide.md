# Creating Organisms (Complex Components)

**You are a Flutter frontend engineer building production-quality organisms.**

**Mobile-First Approach: Design for compact screens, enhance for larger breakpoints.**

## ⚠️ CRITICAL: Flutter Theme-Only Requirement

**ALL spacing, colors, and typography MUST use Flutter theme system only:**
- ❌ **NEVER hardcode values** - No `EdgeInsets.all(16)`, `Colors.blue`, `fontSize: 18`
- ✅ **ALWAYS use theme** - `Theme.of(context).colorScheme.primary`, `Theme.of(context).textTheme.bodyMedium`
- ✅ **Use consistent spacing patterns** - Define theme-based spacing helpers
- ✅ **Follow Material Design 3** - Use semantic color roles and text styles

## Before Creating Any Organism

### 1. Use Existing Molecules First
```dart
// Check lib/molecules/ for:
import 'package:bloom_app/molecules/header.dart';
import 'package:bloom_app/molecules/slider_card.dart';
import 'package:bloom_app/molecules/text_field_card.dart';
```

### 2. Compose with Material 3 + Atoms
Combine existing components rather than building from scratch.

### 3. Keep Responsive Logic Simple
Use consistent responsive patterns, avoid over-engineering.

## Responsive Patterns

### 🏆 Recommended: ScreenSize Enum Pattern
**Best for: Production organisms with consistent spacing and multiple responsive values**

```dart
import '../../core/utils/responsive_utils.dart';

Widget build(BuildContext context) {
  final screenSize = getScreenSize(context);
  return Container(
    padding: _getResponsivePadding(screenSize),
    child: Column(children: [
      // Your content with consistent responsive spacing
    ]),
  );
}

EdgeInsets _getResponsivePadding(ScreenSize screenSize, BuildContext context) {
  final theme = Theme.of(context);
  // ✅ CORRECT: Use theme-based spacing only
  switch (screenSize) {
    case ScreenSize.compact:   // < 600dp
      return EdgeInsets.all(theme.spacing.medium);
    case ScreenSize.medium:    // 600-959dp
      return EdgeInsets.all(theme.spacing.large);
    case ScreenSize.expanded:  // >= 960dp
      return EdgeInsets.all(theme.spacing.extraLarge);
  }
}
```

**Why this is better:**
- ✅ **Consistent breakpoints** across all components (600/960)
- ✅ **Reusable helper methods** reduce code duplication  
- ✅ **Type-safe** with clear semantic meaning
- ✅ **Maintainable** - change breakpoints in one place

### Simple LayoutBuilder Pattern
**Best for: Simple binary layouts (mobile vs desktop)**

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 600;
      return isCompact ? _buildMobileLayout() : _buildDesktopLayout();
    },
  );
}
```

## Key Patterns for Production Organisms

### Pattern 1: Responsive Form Composition
```dart
// Focus: Compose existing molecules with consistent responsive spacing
final screenSize = getScreenSize(context);
return Card(
  child: Padding(
    padding: _getContentPadding(screenSize),
    child: Column(children: [
      // Compose existing molecules
      SliderCard(...),
      SizedBox(height: _getElementSpacing(screenSize)),
      TextFieldCard(...),
      SizedBox(height: _getElementSpacing(screenSize)),
      // Responsive button layout
      _buildResponsiveActions(screenSize),
    ]),
  ),
);

EdgeInsets _getContentPadding(ScreenSize screenSize, BuildContext context) {
  final theme = Theme.of(context);
  // ✅ CORRECT: Theme-based spacing only
  switch (screenSize) {
    case ScreenSize.compact: return EdgeInsets.all(theme.spacing.medium);
    case ScreenSize.medium: return EdgeInsets.all(theme.spacing.large);
    case ScreenSize.expanded: return EdgeInsets.all(theme.spacing.extraLarge);
  }
}
```

### Pattern 2: List Item Composition  
```dart
// Focus: Use Material 3 components + existing molecules
return Card(
  child: ListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: StatusChip(...), // Use existing molecule
    onTap: onTap,
  ),
);
```

### Pattern 3: Responsive Grid/List
```dart
// Focus: Adaptive layouts with consistent responsive spacing
final screenSize = getScreenSize(context);
return screenSize == ScreenSize.compact
  ? ListView(
      padding: _getContentPadding(screenSize, context),
      children: items,
    )
  : GridView(
      padding: _getContentPadding(screenSize, context),
      children: items,
      crossAxisCount: screenSize == ScreenSize.medium ? 2 : 3,
    );
```

## Responsive Typography Rules

### Pattern 4: Responsive Text Styles
```dart
// ALWAYS use Material Design 3 text styles from theme
TextStyle? _getResponsiveTextStyle(BuildContext context, ScreenSize screenSize, MaterialTextStyle baseStyle) {
  final theme = Theme.of(context).textTheme;
  
  switch (baseStyle) {
    case MaterialTextStyle.headline:
      return screenSize == ScreenSize.compact 
        ? theme.headlineSmall
        : screenSize == ScreenSize.medium 
          ? theme.headlineMedium
          : theme.headlineLarge;
          
    case MaterialTextStyle.title:
      return screenSize == ScreenSize.compact
        ? theme.titleMedium
        : theme.titleLarge;
        
    case MaterialTextStyle.body:
      return theme.bodyMedium; // Consistent across all screens
  }
}

// Error state example with responsive typography
Widget _buildErrorState(BuildContext context, String error) {
  final screenSize = getScreenSize(context);
  final theme = Theme.of(context);

  return Container(
    padding: _getResponsivePadding(screenSize, context),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.analytics_outlined,
          // ✅ CORRECT: Theme-based icon sizing
          size: screenSize == ScreenSize.compact
            ? theme.iconTheme.size ?? 24.0
            : (theme.iconTheme.size ?? 24.0) * 1.5,
          color: theme.colorScheme.error,
        ),
        // ✅ CORRECT: Theme-based spacing
        SizedBox(height: theme.spacing.medium),
        Text(
          'Unable to Load Results',
          style: _getResponsiveTextStyle(context, screenSize, MaterialTextStyle.headline)?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        // ✅ CORRECT: Theme-based spacing
        SizedBox(height: theme.spacing.small),
        Text(
          error,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
```

**Typography Best Practices:**
- ✅ **Always use Material Design 3 text styles** from `Theme.of(context).textTheme`
- ✅ **Scale headlines responsively** (headlineSmall → headlineMedium → headlineLarge)
- ✅ **Keep body text consistent** across all screen sizes for readability
- ✅ **Use semantic color roles** (`onSurface`, `onSurfaceVariant`, `error`)
- ✅ **Never hardcode text sizes** - use theme system

### Helper Enum for Text Styles
```dart
enum MaterialTextStyle {
  headline,
  title,
  body,
}
```

## Core Principles

1. **🎯 THEME-FIRST REQUIREMENT** - ALL spacing, colors, typography MUST use Flutter theme system only
   - ❌ Never: `EdgeInsets.all(16)`, `Colors.blue`, `fontSize: 18`
   - ✅ Always: `theme.spacing.medium`, `theme.colorScheme.primary`, `theme.textTheme.bodyMedium`
2. **Compose existing molecules/atoms** - Don't reinvent components
3. **Use consistent responsive patterns** - Prefer `ScreenSize` enum for production, `LayoutBuilder` for simple cases
4. **Use Material 3 components** - Leverage `Card`, `ListTile`, etc.
5. **Follow theme system** - Use `Theme.of(context)` and avoid hardcoded values
6. **Scale typography responsively** - Headlines scale up, body text stays consistent
7. **Maintain consistent breakpoints** - Use 600dp/960dp across all organisms

## Quick Checklist

- [ ] **⚠️ CRITICAL: ALL spacing, colors, typography use Flutter theme only** (no hardcoded values)
- [ ] Compose existing molecules/atoms
- [ ] Use `ScreenSize` enum for responsive spacing (or `LayoutBuilder` for simple layouts)
- [ ] Import `../../core/utils/responsive_utils.dart`
- [ ] Follow theme system (no hardcoded colors/sizes)
- [ ] Use responsive typography with Material Design 3 text styles
- [ ] Use consistent breakpoints (600dp/960dp)
- [ ] Test on mobile, tablet, and desktop

### Theme Compliance Examples:
- ✅ `EdgeInsets.all(theme.spacing.medium)`
- ✅ `color: theme.colorScheme.primary`
- ✅ `style: theme.textTheme.bodyMedium`
- ❌ `EdgeInsets.all(16.0)`
- ❌ `color: Colors.blue`
- ❌ `fontSize: 18.0`