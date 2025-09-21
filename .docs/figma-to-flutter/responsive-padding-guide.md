# Responsive Padding Guide

**You are a Flutter frontend engineer implementing responsive padding for production-quality mobile and web applications.**

## Core Principle: ScreenSize Enum Pattern

**Use the recommended ScreenSize enum pattern for consistent responsive spacing across all components.**

```dart
import '../../core/utils/responsive_utils.dart';

// ✅ PRODUCTION STANDARD: ScreenSize enum pattern
EdgeInsets _getResponsivePadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:   // < 600dp
      return const EdgeInsets.all(16.0);
    case ScreenSize.medium:    // 600-959dp
      return const EdgeInsets.all(20.0);
    case ScreenSize.expanded:  // >= 960dp
      return const EdgeInsets.all(24.0);
  }
}

Widget build(BuildContext context) {
  final screenSize = getScreenSize(context);
  return Container(
    padding: _getResponsivePadding(screenSize),
    child: YourContent(),
  );
}
```

## Responsive Padding Standards

### 8dp Grid System (Material Design 3)

**Standard Responsive Padding Values:**

| Screen Size | Breakpoint | Horizontal Padding | Vertical Padding | Use Case |
|-------------|------------|-------------------|------------------|----------|
| **Compact**   | < 600dp    | 16dp              | 16dp             | Mobile phones |
| **Medium**    | 600-959dp  | 20dp              | 20dp             | Tablets |
| **Expanded**  | ≥ 960dp    | 24dp              | 24dp             | Desktop |

**Alternative Spacing Scales:**

```dart
// Tight spacing (for cards, list items)
EdgeInsets _getTightPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact: return const EdgeInsets.all(12.0);
    case ScreenSize.medium: return const EdgeInsets.all(16.0);
    case ScreenSize.expanded: return const EdgeInsets.all(20.0);
  }
}

// Generous spacing (for main content areas)
EdgeInsets _getGenerousPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact: return const EdgeInsets.all(20.0);
    case ScreenSize.medium: return const EdgeInsets.all(24.0);
    case ScreenSize.expanded: return const EdgeInsets.all(32.0);
  }
}

// Asymmetric padding (horizontal/vertical different)
EdgeInsets _getAsymmetricPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    case ScreenSize.medium:
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
    case ScreenSize.expanded:
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0);
  }
}
```

## Implementation Patterns

### Pattern 1: Basic Container Padding

```dart
class ResponsiveContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    return Container(
      padding: _getContentPadding(screenSize),
      child: child,
    );
  }

  EdgeInsets _getContentPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact: return const EdgeInsets.all(16.0);
      case ScreenSize.medium: return const EdgeInsets.all(20.0);
      case ScreenSize.expanded: return const EdgeInsets.all(24.0);
    }
  }
}
```

### Pattern 2: Card Content Padding

```dart
class ResponsiveCard extends StatelessWidget {
  final Widget child;

  const ResponsiveCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    return Card(
      child: Padding(
        padding: _getCardPadding(screenSize),
        child: child,
      ),
    );
  }

  EdgeInsets _getCardPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact: return const EdgeInsets.all(16.0);
      case ScreenSize.medium: return const EdgeInsets.all(20.0);
      case ScreenSize.expanded: return const EdgeInsets.all(24.0);
    }
  }
}
```

### Pattern 3: List/Scroll View Padding

```dart
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveListView({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    return ListView(
      padding: _getListPadding(screenSize),
      children: children,
    );
  }

  EdgeInsets _getListPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case ScreenSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
      case ScreenSize.expanded:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    }
  }
}
```

### Pattern 4: Complex Multi-Area Padding

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget header;
  final Widget content;
  final Widget? footer;

  const ResponsiveLayout({
    super.key,
    required this.header,
    required this.content,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    return Column(
      children: [
        Padding(
          padding: _getHeaderPadding(screenSize),
          child: header,
        ),
        Expanded(
          child: Padding(
            padding: _getContentPadding(screenSize),
            child: content,
          ),
        ),
        if (footer != null)
          Padding(
            padding: _getFooterPadding(screenSize),
            child: footer!,
          ),
      ],
    );
  }

  EdgeInsets _getHeaderPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0);
      case ScreenSize.medium:
        return const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0);
      case ScreenSize.expanded:
        return const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0);
    }
  }

  EdgeInsets _getContentPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact: return const EdgeInsets.all(16.0);
      case ScreenSize.medium: return const EdgeInsets.all(20.0);
      case ScreenSize.expanded: return const EdgeInsets.all(24.0);
    }
  }

  EdgeInsets _getFooterPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0);
      case ScreenSize.medium:
        return const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0);
      case ScreenSize.expanded:
        return const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0);
    }
  }
}
```

## Common Responsive Padding Scenarios

### Safe Area Considerations

```dart
// For screens that need SafeArea compatibility
EdgeInsets _getSafeAreaPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    case ScreenSize.medium:
      return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
    case ScreenSize.expanded:
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0);
  }
}

Widget build(BuildContext context) {
  final screenSize = getScreenSize(context);
  return SafeArea(
    child: Padding(
      padding: _getSafeAreaPadding(screenSize),
      child: content,
    ),
  );
}
```

### Bottom Sheet/Modal Padding

```dart
EdgeInsets _getModalPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:
      return const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0);
    case ScreenSize.medium:
      return const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0);
    case ScreenSize.expanded:
      return const EdgeInsets.fromLTRB(32.0, 40.0, 32.0, 32.0);
  }
}
```

### Form Input Padding

```dart
EdgeInsets _getFormFieldPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact: return const EdgeInsets.all(12.0);
    case ScreenSize.medium: return const EdgeInsets.all(16.0);
    case ScreenSize.expanded: return const EdgeInsets.all(20.0);
  }
}
```

## Best Practices

### ✅ DO

- **Use ScreenSize enum pattern** for consistent breakpoints (600dp/960dp)
- **Follow 8dp grid system** with multiples of 4dp/8dp values
- **Scale padding progressively** from mobile → tablet → desktop
- **Create reusable helper methods** for common padding scenarios
- **Consider content type** (cards need different padding than full-screen layouts)
- **Test on all screen sizes** to ensure proper spacing

### ❌ DON'T

- **Never hardcode padding values** without responsive consideration
- **Don't use random padding values** that break the 8dp grid system
- **Avoid LayoutBuilder** for simple padding scenarios (use ScreenSize enum)
- **Don't ignore SafeArea** requirements on mobile devices
- **Never use identical padding** across all screen sizes
- **Don't create inconsistent breakpoints** across components

## Quick Implementation Checklist

- [ ] Import `../../core/utils/responsive_utils.dart`
- [ ] Use `getScreenSize(context)` to determine screen size
- [ ] Create `_getResponsivePadding(ScreenSize screenSize)` helper method
- [ ] Follow 8dp grid system (16dp, 20dp, 24dp progression)
- [ ] Use consistent breakpoints: 600dp and 960dp
- [ ] Test padding on mobile, tablet, and desktop
- [ ] Ensure SafeArea compatibility where needed
- [ ] Verify padding looks appropriate with actual content

## Contextual Spacing System

### Page Edge Padding (STANDARDIZED - Material Design 3 Compliant)

**Use `context.pageEdgePadding` for consistent page-level spacing across all screen sizes:**

**Generous spacing approach**: Our implementation provides slightly more generous padding than Material Design 3's baseline (16dp mobile, 24dp tablet) for a premium, spacious feel while maintaining full MD3 compliance.

```dart
import '../../core/themes/spacing_theme.dart';

// ✅ RECOMMENDED: Use standardized page edge padding
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: context.pageEdgePadding, // Auto-responsive: 20px → 24px → 32px
      child: YourPageContent(),
    ),
  );
}

// Alternative: Access individual values
EdgeInsets _getPagePadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact: return EdgeInsets.all(context.spacing.lgPlus); // 20px
    case ScreenSize.medium: return EdgeInsets.all(context.spacing.xl);      // 24px
    case ScreenSize.expanded: return EdgeInsets.all(context.spacing.xxl);   // 32px
  }
}
```

### Contextual Spacing Values

**Use `context.spacing` for consistent component-level spacing:**

```dart
// Standard spacing values (8dp grid system)
context.spacing.xs      // 4px  - Micro adjustments, icon spacing
context.spacing.sm      // 8px  - Component internal padding
context.spacing.md      // 12px - Small component gaps
context.spacing.lg      // 16px - Standard content padding
context.spacing.lgPlus  // 20px - Content padding with extra space
context.spacing.xl      // 24px - Section separation
context.spacing.xxl     // 32px - Large content blocks
context.spacing.xxxl    // 48px - Major page sections
```

### Contextual Spacing Instructions

**When working with contextual spacing, use these clear instruction patterns:**

#### Page-Level Spacing:
- **"Use page edge padding"** → `context.pageEdgePadding`
- **"Use standard page margins"** → `context.pageEdgePadding`
- **"Edge of cards to edge of page"** → Page-level padding

#### Component Spacing:
- **"Use standard spacing"** → `context.spacing.lg` (16px)
- **"Use tight spacing"** → `context.spacing.md` (12px)
- **"Use loose spacing"** → `context.spacing.xl` (24px)
- **"Between components"** → Content/section spacing
- **"Inside components"** → Internal padding

#### Responsive Instructions:
- **"Mobile: X, Tablet: Y, Desktop: Z"** → Custom responsive helper
- **"Responsive content spacing"** → Create appropriate breakpoints
- **"Use responsive [component] spacing"** → Look for existing patterns

#### Clear Directives:
- **"Standardize all [page/component] spacing"** → Create consistent helper
- **"Make spacing consistent across [feature]"** → Update all related files
- **"Use design tokens for [specific spacing]"** → `DesignTokens.spacingX`

### Example: Converting to Contextual Spacing

```dart
// ❌ OLD: Hardcoded responsive padding
EdgeInsets _getContentPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact: return const EdgeInsets.all(20.0);
    case ScreenSize.medium: return const EdgeInsets.all(24.0);
    case ScreenSize.expanded: return const EdgeInsets.all(32.0);
  }
}

// ✅ NEW: Contextual spacing
EdgeInsets _getContentPadding(ScreenSize screenSize) {
  return context.pageEdgePadding; // Automatically handles 20px → 24px → 32px
}

// ✅ EVEN BETTER: Direct usage
Widget build(BuildContext context) {
  return Container(
    padding: context.pageEdgePadding,
    child: content,
  );
}
```

## Common Values Reference

### Material Design 3 Compliance

```dart
// 🎯 BLOOM APP PAGE EDGE PADDING (STANDARDIZED - Generous MD3 Approach)
Compact:  20dp → Medium: 24dp → Expanded: 32dp  // context.pageEdgePadding

// 📐 Material Design 3 Baseline (for reference)
MD3 Mobile: 16dp → MD3 Tablet: 24dp → MD3 Desktop: 24dp+

// ✅ Our approach: Generous but fully MD3 compliant
// - Mobile: 20dp (vs MD3's 16dp) = More spacious, premium feel
// - Tablet: 24dp (matches MD3) = Perfect alignment
// - Desktop: 32dp (vs MD3's 24dp+) = Enhanced desktop experience
```

### Additional Spacing Progressions

```dart
// Standard progression (follows MD3 baseline closer)
Compact:  16dp → Medium: 20dp → Expanded: 24dp

// Tight progression (for dense layouts)
Compact:  12dp → Medium: 16dp → Expanded: 20dp

// Generous progression (matches our page edge approach)
Compact:  20dp → Medium: 24dp → Expanded: 32dp

// Micro adjustments (for fine-tuning)
Compact:   8dp → Medium: 12dp → Expanded: 16dp

// 🎨 Contextual spacing values (8dp grid system)
context.spacing.xs (4px) → sm (8px) → md (12px) → lg (16px) → lgPlus (20px) → xl (24px) → xxl (32px) → xxxl (48px)
```

Use this guide to ensure consistent, responsive padding across your Flutter application that provides optimal user experience on all device types. Always prefer contextual spacing (`context.spacing`, `context.pageEdgePadding`) over hardcoded values.