# Creating a New Page in Flutter

**Mobile-First Responsive Development**

This guide focuses on creating responsive Flutter pages using a **mobile-first approach**. We design and implement for mobile devices first (compact breakpoints), then enhance the experience for larger screens (tablets and desktop). While our primary focus is mobile-optimized responsive design, we maintain careful attention to desktop styling differences that improve the desktop user experience without compromising mobile functionality.

## Figma to Flutter Theme Mapping

### 1. Extract from Figma
Use `#fig` shortcut to run all Figma MCP commands:
- `get_variable_defs` - Extract design tokens
- `get_code` - Generate component code
- `get_image` - Get visual reference

### 2. Map to Existing Theme
**CRITICAL: Only use values that exist in `lib/theme/design_tokens.dart`**

#### Color Mapping
```dart
// Figma variables → Flutter theme
M3/Light/* → DesignTokens.light*
M3/Dark/* → DesignTokens.dark*
M3/Pink-DT/* → DesignTokens.pinkDark*

// Usage: Always through theme context
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.surface
```

#### Typography Mapping
```dart
// Figma variables → Flutter theme (Material Design 3 Type Scale)
Static/Display-* → DesignTokens.display* // 57sp/45sp/36sp
Static/Headline-* → DesignTokens.headline* // 32sp/28sp/24sp
Static/Title-* → DesignTokens.title* // 22sp/16sp/14sp
Static/Body-* → DesignTokens.body* // 16sp/14sp/12sp
Static/Label-* → DesignTokens.label* // 14sp/12sp/11sp

// Usage: Through theme or direct reference
Theme.of(context).textTheme.headlineMedium
DesignTokens.bodyLarge

// Material Design 3 Typography Scale Requirements:
// - Display: Large headlines, hero text (57sp, 45sp, 36sp)
// - Headline: Page titles, major sections (32sp, 28sp, 24sp)
// - Title: Card headers, list headers (22sp, 16sp, 14sp)
// - Body: Main content, reading text (16sp, 14sp, 12sp)
// - Label: Buttons, tabs, form labels (14sp, 12sp, 11sp)
```

#### Spacing & Layout
```dart
// Material Design 3 8dp Grid System
DesignTokens.spacing4   // 4dp  - Micro spacing
DesignTokens.spacing8   // 8dp  - Component internal padding
DesignTokens.spacing12  // 12dp - Small gaps, compact layouts
DesignTokens.spacing16  // 16dp - Standard content padding
DesignTokens.spacing24  // 24dp - Section spacing, card padding
DesignTokens.spacing32  // 32dp - Large section breaks
DesignTokens.spacing48  // 48dp - Major page sections

// Border Radius (Material Design 3 Shapes)
DesignTokens.radiusSmall  // 8dp  - Input fields, small components
DesignTokens.radiusMedium // 12dp - Cards, containers
DesignTokens.radiusLarge  // 20dp - Large surfaces, modals

// Elevation (Material Design 3 System)
DesignTokens.elevation0  // 0dp - No shadow
DesignTokens.elevation1  // 1dp - Cards at rest
DesignTokens.elevation2  // 3dp - Cards on hover/focus
DesignTokens.elevation3  // 6dp - Modals, menus
DesignTokens.elevation4  // 8dp - Navigation drawers
DesignTokens.elevation5  // 12dp - Floating action buttons
```

### 3. Implementation Rules (Mobile-First)
- **Never hardcode colors, sizes, or fonts**
- **Always use theme values or DesignTokens**
- **Design mobile-first** - start with compact layouts, then enhance for larger screens
- **Default to dark theme** - design and test primarily in dark mode
- **Use Material 3 components** from Flutter SDK
- **Follow 8dp grid system** for all spacing and sizing
- **Maintain 48dp minimum touch targets** across all screen sizes for accessibility
- **Use semantic typography** (Display for heroes, Headline for titles, Body for content)
- **Progressive enhancement** - desktop builds upon mobile patterns with refined spacing and typography
- **Ensure WCAG AA contrast ratios** using theme colors

## 🚨 CRITICAL: Android/iOS Mobile Layout Requirements

**MANDATORY for every new page - These prevent mobile display cutoff issues:**

### 1. SafeArea Wrapper (Required)
```dart
// ALWAYS wrap Scaffold body content in SafeArea
Scaffold(
  body: SafeArea(  // ✅ REQUIRED - Prevents content cutoff by system UI
    child: CustomScrollView(
      // Your content here
    ),
  ),
)
```

### 2. FloatingActionButton Mobile Positioning (If Used)
```dart
// ALWAYS add system UI padding to FloatingActionButtons
floatingActionButton: Padding(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom + // Keyboard
            MediaQuery.of(context).padding.bottom,     // System navigation
  ),
  child: FloatingActionButton(
    // Your FAB content
  ),
),
```

### 3. Bottom Content Spacing (Required for Scroll Views)
```dart
// ALWAYS add system UI padding to bottom spacing
SliverPadding(
  padding: EdgeInsets.only(
    bottom: DesignTokens.spacing48 + MediaQuery.of(context).padding.bottom
  ),
),

// For regular Column/ListView:
SizedBox(height: DesignTokens.spacing48 + MediaQuery.of(context).padding.bottom),
```

### 4. Keyboard Handling for Text Input
```dart
// ALWAYS add keyboard avoidance for pages with text input
Scaffold(
  resizeToAvoidBottomInset: true,  // ✅ REQUIRED for text input pages
  body: SafeArea(
    child: // Your content
  ),
)
```

### 5. Positioned Elements (If Used)
```dart
// ALWAYS wrap positioned UI elements with SafeArea
Positioned(
  top: MediaQuery.of(context).padding.top + 16,
  left: 16,
  child: SafeArea(  // ✅ Additional SafeArea for positioned elements
    child: Container(
      // Your positioned content
    ),
  ),
),
```

### Mobile Layout Checklist
**Before completing any new page, verify:**
- [ ] `SafeArea` wrapper around main content
- [ ] `FloatingActionButton` has proper bottom padding (if used)  
- [ ] Bottom content spacing includes system UI padding
- [ ] `resizeToAvoidBottomInset: true` for pages with text input
- [ ] Positioned elements wrapped in additional `SafeArea` (if used)
- [ ] No hardcoded status bar heights or system UI dimensions
- [ ] Uses `MediaQuery.of(context).padding` for system UI measurements

## 📱 Mobile Scrolling Architecture Best Practices

**CRITICAL: Proper scrolling architecture is fundamental to mobile UX, not just an optimization.**

### When to Use CustomScrollView vs Single ScrollView

#### Use CustomScrollView + Slivers When:
- **Page has title/header that should scroll with content** (most common case)
- **Multiple scrollable sections** (lists, grids, content blocks)
- **Loading/error states need to fill remaining space**
- **Future features** like pull-to-refresh, sticky headers, or nested scrolling
- **Performance matters** with large lists or complex layouts

#### Use Single ScrollView When:
- **Simple static content** with no dynamic lists
- **Very basic pages** with just text and buttons
- **Absolutely no complex scrolling requirements**

### Sliver Architecture Benefits

```dart
// ✅ RECOMMENDED: CustomScrollView with Slivers
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(), // iOS-style bouncing
  ),
  slivers: [
    // Title scrolls with content, proper alignment
    SliverPadding(
      padding: EdgeInsets.fromLTRB(32, 24, 32, 32),
      sliver: SliverToBoxAdapter(
        child: Text('Page Title', style: Theme.of(context).textTheme.displaySmall),
      ),
    ),
    // Optimized list rendering
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => CardWidget(data[index]),
        childCount: data.length,
      ),
    ),
  ],
),

// ❌ AVOID: Column + Expanded + ListView
Column(
  children: [
    Text('Page Title'), // Fixed, doesn't scroll with content
    Expanded(
      child: ListView.builder(...), // Sub-optimal scroll behavior
    ),
  ],
),
```

### Mobile Scroll Physics Configuration

```dart
// ALWAYS use these physics for mobile-optimized scrolling
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  ),
  // AlwaysScrollableScrollPhysics: Ensures scroll indicators always visible
  // BouncingScrollPhysics: iOS-style bouncing behavior for better mobile UX
  slivers: [...],
)
```

### Implementation Patterns

#### 1. Page with Scrolling Title (Most Common)
```dart
class ScrollingTitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Title scrolls with content, aligned with card content
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16, // Align with card content (16px outer + 16px card padding)
                  24, // Top spacing
                  16, // Align with card content
                  32, // Bottom spacing before list
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Page Title',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
              // Optimized list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Card(child: ListTile(title: Text('Item $index'))),
                  ),
                  childCount: items.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 2. Loading/Error States with SliverFillRemaining
```dart
Widget _buildContentSliver() {
  if (_isLoading) {
    return SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()),
    );
  }
  
  if (_error != null) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48),
            SizedBox(height: 16),
            Text('Error loading data'),
            SizedBox(height: 16),
            FilledButton(
              onPressed: _retry,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  if (_data.isEmpty) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64),
            SizedBox(height: 16),
            Text('No data available'),
            SizedBox(height: 16),
            FilledButton(
              onPressed: _create,
              child: Text('Create New'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Normal list content
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) => _buildListItem(_data[index]),
      childCount: _data.length,
    ),
  );
}
```

#### 3. Mixed Content Types
```dart
CustomScrollView(
  slivers: [
    // Header section
    SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(radius: 40),
            SizedBox(height: 16),
            Text('User Profile', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ),
    
    // Section divider
    SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
      ),
    ),
    
    // Dynamic list
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ActivityCard(activities[index]),
        childCount: activities.length,
      ),
    ),
    
    // Bottom spacing for system UI
    SliverPadding(
      padding: EdgeInsets.only(
        bottom: 48 + MediaQuery.of(context).padding.bottom,
      ),
    ),
  ],
),
```

### Common Anti-patterns to Avoid

#### ❌ Fixed Title + Expanded ListView
```dart
// AVOID: Title doesn't scroll, poor mobile UX
Column(
  children: [
    Padding(
      padding: EdgeInsets.all(24),
      child: Text('Fixed Title'), // Doesn't scroll with content
    ),
    Expanded(
      child: ListView.builder(...), // Separate scroll context
    ),
  ],
),
```

#### ❌ Nested Scroll Views
```dart
// AVOID: Competing scroll physics
SingleChildScrollView(
  child: Column(
    children: [
      Container(height: 200, child: ListView(...)), // Nested scrolling issues
      Container(height: 300, child: GridView(...)), // Multiple scroll contexts
    ],
  ),
),
```

#### ❌ Missing Scroll Physics
```dart
// AVOID: Default physics, poor mobile feel
ListView.builder(...), // Missing AlwaysScrollableScrollPhysics + BouncingScrollPhysics
```

### Responsive Scroll Considerations

```dart
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(),
  ),
  slivers: [
    // Responsive title padding
    SliverPadding(
      padding: EdgeInsets.fromLTRB(
        _getTitleHorizontalPadding(screenSize),
        _getTitleTopPadding(screenSize),
        _getTitleHorizontalPadding(screenSize),
        _getTitleBottomPadding(screenSize),
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          'Page Title',
          style: _getTitleStyle(screenSize),
        ),
      ),
    ),
    
    // Responsive content padding
    SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: _getContentHorizontalPadding(screenSize),
      ),
      sliver: _buildContentSliver(),
    ),
  ],
),
```

### Decision Matrix: Scroll Architecture

| Use Case | Architecture | Reason |
|----------|-------------|---------|
| List page with title | CustomScrollView + SliverPadding + SliverList | Title scrolls with content, optimized rendering |
| Simple form | SingleChildScrollView | Static content, no dynamic lists |
| Dashboard with sections | CustomScrollView + multiple slivers | Mixed content types, future extensibility |
| Loading states | CustomScrollView + SliverFillRemaining | Proper space filling, consistent architecture |
| Pull-to-refresh needed | CustomScrollView + RefreshIndicator | Slivers required for pull-to-refresh |

### Scrolling Architecture Checklist

**Before implementing scrollable content:**
- [ ] Choose CustomScrollView for pages with titles or dynamic content
- [ ] Add `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())`
- [ ] Use `SliverPadding` for title sections that scroll with content
- [ ] Use `SliverFillRemaining` for loading/error/empty states
- [ ] Use `SliverList` instead of `ListView.builder` within CustomScrollView
- [ ] Align title padding with card content (account for card internal padding)
- [ ] Add bottom padding that includes system UI safe area
- [ ] Test scroll behavior across different content lengths
- [ ] Verify scroll indicators appear correctly
- [ ] Ensure smooth scroll physics on mobile devices

## Material Design 3 Component Sizing Guidelines

### Core Component Dimensions
```dart
// Material Design 3 Standard Component Heights
const double buttonHeight = 48.0;        // Standard button height
const double buttonHeightCompact = 36.0; // Compact button height
const double textFieldHeight = 56.0;     // Standard text field height
const double appBarHeight = 64.0;        // Standard app bar height
const double appBarHeightCompact = 56.0; // Compact app bar height
const double listTileHeight = 72.0;      // Standard list tile height
const double chipHeight = 32.0;          // Standard chip height
const double tabHeight = 48.0;           // Standard tab height

// Touch Target Requirements
const double minTouchTarget = 48.0;      // Minimum touch target (accessibility)
const double desktopTouchTarget = 44.0;  // Desktop mouse/trackpad target

// Icon Sizes (Material Design 3 Icon System)
const double iconSmall = 16.0;           // Small icons, inline with text
const double iconMedium = 24.0;          // Standard UI icons
const double iconLarge = 32.0;           // Prominent action icons
const double iconExtraLarge = 48.0;      // Hero icons, empty states
```

### Responsive Component Sizing
```dart
// Get component dimensions based on screen size
double getButtonHeight(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return 48.0;  // Mobile touch optimized
    case ScreenSize.medium:
      return 48.0;  // Tablet touch optimized
    case ScreenSize.expanded:
      return 44.0;  // Desktop mouse/trackpad optimized
  }
}

double getTextFieldHeight(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return 56.0;  // Standard height for mobile
    case ScreenSize.medium:
    case ScreenSize.expanded:
      return 48.0;  // Slightly reduced for desktop density
  }
}

double getAppBarHeight(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return 56.0;  // Standard mobile app bar
    case ScreenSize.medium:
    case ScreenSize.expanded:
      return 64.0;  // Larger for desktop with more content
  }
}
```

### Component Padding & Margins
```dart
// Material Design 3 Internal Component Padding
class ComponentPadding {
  // Button internal padding
  static EdgeInsets buttonPadding(ScreenSize size) {
    return EdgeInsets.symmetric(
      horizontal: size == ScreenSize.expanded 
        ? DesignTokens.spacing24    // 24dp desktop
        : DesignTokens.spacing16,   // 16dp mobile/tablet
      vertical: DesignTokens.spacing12, // 12dp vertical consistent
    );
  }
  
  // Text field internal padding
  static EdgeInsets textFieldPadding(ScreenSize size) {
    return EdgeInsets.all(
      size == ScreenSize.compact 
        ? DesignTokens.spacing16    // 16dp mobile
        : DesignTokens.spacing12,   // 12dp tablet/desktop
    );
  }
  
  // Card content padding
  static EdgeInsets cardPadding(ScreenSize size) {
    switch (size) {
      case ScreenSize.compact:
        return EdgeInsets.all(DesignTokens.spacing16);  // 16dp mobile
      case ScreenSize.medium:
        return EdgeInsets.all(DesignTokens.spacing20);  // 20dp tablet
      case ScreenSize.expanded:
        return EdgeInsets.all(DesignTokens.spacing24);  // 24dp desktop
    }
  }
  
  // List tile padding
  static EdgeInsets listTilePadding(ScreenSize size) {
    return EdgeInsets.symmetric(
      horizontal: size == ScreenSize.compact 
        ? DesignTokens.spacing16    // 16dp mobile
        : DesignTokens.spacing24,   // 24dp tablet/desktop
      vertical: DesignTokens.spacing8,     // 8dp consistent
    );
  }
}
```

### Material 3 Button Sizing Implementation
```dart
Widget buildMaterialButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  ButtonType type = ButtonType.filled,
}) {
  final screenSize = getScreenSize(context);
  final buttonHeight = getButtonHeight(screenSize);
  
  switch (type) {
    case ButtonType.filled:
      if (screenSize == ScreenSize.compact) {
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              padding: ComponentPadding.buttonPadding(screenSize),
            ),
            child: Text(label, style: DesignTokens.labelLarge),
          ),
        );
      } else {
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenSize == ScreenSize.medium ? 120.0 : 140.0,
              minHeight: buttonHeight,
            ),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: ComponentPadding.buttonPadding(screenSize),
              ),
              child: Text(label, style: DesignTokens.labelLarge),
            ),
          ),
        );
      }
      
    case ButtonType.outlined:
      if (screenSize == ScreenSize.compact) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              padding: ComponentPadding.buttonPadding(screenSize),
            ),
            child: Text(label, style: DesignTokens.labelLarge),
          ),
        );
      } else {
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 88.0,
              minHeight: buttonHeight,
            ),
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: ComponentPadding.buttonPadding(screenSize),
              ),
              child: Text(label, style: DesignTokens.labelLarge),
            ),
          ),
        );
      }
      
    case ButtonType.text:
      if (screenSize == ScreenSize.compact) {
        return SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              padding: ComponentPadding.buttonPadding(screenSize),
            ),
            child: Text(label, style: DesignTokens.labelLarge),
          ),
        );
      } else {
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 64.0,
              minHeight: buttonHeight,
            ),
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                padding: ComponentPadding.buttonPadding(screenSize),
              ),
              child: Text(label, style: DesignTokens.labelLarge),
            ),
          ),
        );
      }
  }
}

enum ButtonType { filled, outlined, text }
```

## Component Reuse Guidelines

### IMPORTANT: Always Use Existing Components

**Before creating any new components:**
1. **Use Material Design 3 components from Flutter SDK** - FilledButton, OutlinedButton, TextButton, Card, TextField, etc.
2. **Check the `lib/molecules/` folder** - Contains custom reusable UI components
3. **Use existing components whenever possible** - They are already tested and follow design patterns
4. **If a new component is needed, notify the user first** - Get approval before creating new components
5. **Never duplicate existing functionality** - Always prefer composition over duplication

### Material Design 3 Components (Flutter SDK)

Flutter provides built-in Material Design 3 components that should be used as the foundation:

```dart
// Material 3 Buttons
FilledButton(
  onPressed: () {},
  child: Text('Primary Action'),
);

FilledButton.tonal(
  onPressed: () {},
  child: Text('Secondary Action'),
);

OutlinedButton(
  onPressed: () {},
  child: Text('Alternative Action'),
);

TextButton(
  onPressed: () {},
  child: Text('Low Emphasis'),
);

// Material 3 Cards
Card(
  elevation: 0,  // Material 3 uses elevation 0 by default
  child: Padding(
    padding: EdgeInsets.all(DesignTokens.spacing16),
    child: content,
  ),
);

// Material 3 TextFields
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint text',
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
    ),
  ),
);

// Material 3 Chips
Chip(
  label: Text('Filter'),
  onDeleted: () {},
);

FilterChip(
  label: Text('Category'),
  selected: isSelected,
  onSelected: (bool value) {},
);

// Material 3 Navigation
NavigationBar(
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
  ],
);

// Material 3 AppBar
AppBar(
  title: Text('Page Title'),
  centerTitle: false,  // Material 3 default
);

// Material 3 FAB
FloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
);

FloatingActionButton.extended(
  onPressed: () {},
  label: Text('Create'),
  icon: Icon(Icons.add),
);

// Material 3 Dialog
AlertDialog(
  title: Text('Title'),
  content: Text('Content'),
  actions: [
    TextButton(onPressed: () {}, child: Text('Cancel')),
    FilledButton(onPressed: () {}, child: Text('Confirm')),
  ],
);

// Material 3 Snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    action: SnackBarAction(
      label: 'Action',
      onPressed: () {},
    ),
  ),
);

// Material 3 Switch
Switch(
  value: true,
  onChanged: (bool value) {},
);

// Material 3 Slider
Slider(
  value: 0.5,
  onChanged: (double value) {},
);

// Material 3 Progress Indicators
LinearProgressIndicator();
CircularProgressIndicator();
```

### REQUIRED: Use Existing Molecules Components

**IMPORTANT: For custom UI components, you MUST use the existing molecules from `/Users/lizzieteo/Development/bloom-app/lib/molecules/`**

Available molecules components in this project:

```dart
// ALWAYS import and use these existing molecules:
import 'package:bloom_app/molecules/header.dart';
import 'package:bloom_app/molecules/slider_card.dart';
import 'package:bloom_app/molecules/text_field_card.dart';

// Header component - USE THIS instead of creating custom headers
Header(
  title: 'Page Title',
  imageUrl: 'https://example.com/image.png',
  backgroundColor: Theme.of(context).colorScheme.primary,
  iconBackgroundColor: Colors.yellow,
);

// SliderCard - USE THIS for any slider/rating questions
SliderCard(
  questionTitle: 'How are you feeling?',
  questionName: 'On a scale of 0-100',
  minLabel: 'Not great',
  maxLabel: 'Amazing',
  value: 50,
  onChanged: (int value) {},
);

// TextFieldCard - USE THIS for any text input questions
TextFieldCard(
  questionTitle: 'Tell us more',
  questionName: 'What\'s on your mind?',
  onChanged: (String value) {},
  hintText: 'Enter your thoughts...',
  maxLines: 3,
);
```

### Component Usage Priority

When building pages, follow this strict priority order:

1. **Check `/lib/molecules/` FIRST** - Always use Header, SliderCard, TextFieldCard if they fit your needs
2. **Material Design 3 SDK Components** - Use FilledButton, Card, TextField, etc. from Flutter SDK for standard components
3. **Composition** - Combine existing molecules and Material 3 components
4. **Extension** - Wrap or extend existing components if modifications are needed
5. **New Component** - ONLY create new components after getting explicit user approval

### When Building New Pages

1. **Start with Material Design 3 components** from Flutter SDK
2. **Check lib/molecules/ folder** for custom components
3. **Compose pages using existing components** rather than creating new widgets
4. **If modification is needed**, consider extending or wrapping existing components
5. **Request approval** before creating any new component files

### Example: Composing a Page with Existing Components

```dart
class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Custom Header from molecules/
          Header(
            title: 'Welcome',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(DesignTokens.spacing16),
                child: Column(
                  children: [
                    // Material 3 Card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(DesignTokens.spacing16),
                        child: Column(
                          children: [
                            // Custom SliderCard from molecules/
                            SliderCard(
                              questionTitle: 'Energy Level',
                              questionName: 'How energized do you feel?',
                              minLabel: 'Exhausted',
                              maxLabel: 'Energized',
                              value: 50,
                              onChanged: (value) {},
                            ),
                            SizedBox(height: DesignTokens.spacing16),
                            // Material 3 FilledButton
                            FilledButton(
                              onPressed: () {},
                              child: Text('Continue'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Page Structure

### Basic Page with Edge-to-Edge Header

```dart
class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Header: Always edge-to-edge, full width
          buildResponsiveHeader(
            screenSize: screenSize, 
            title: 'Page Title',
          ),
          
          // Content: Respects breakpoint constraints
          Expanded(
            child: SafeArea(
              child: _buildResponsiveContent(screenSize),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResponsiveContent(ScreenSize screenSize) {
    // Content follows form breakpoint constraints
    switch (screenSize) {
      case ScreenSize.compact:
        return Padding(
          padding: EdgeInsets.all(DesignTokens.spacing16),
          child: _buildPageContent(),
        );
      case ScreenSize.medium:
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.spacing24),
              child: _buildPageContent(),
            ),
          ),
        );
      case ScreenSize.expanded:
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.spacing32),
              child: _buildPageContent(),
            ),
          ),
        );
    }
  }
  
  Widget _buildPageContent() {
    // Your page content goes here
    return Column(
      children: [
        // Forms, buttons, content, etc.
      ],
    );
  }
}
```

### Alternative: Page with AppBar (when header not needed)

```dart
class NewPageWithAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Page Title',
          style: screenSize == ScreenSize.compact 
            ? DesignTokens.titleLarge      // 22sp on mobile
            : DesignTokens.headlineSmall,  // 24sp on tablet/desktop
        ),
        toolbarHeight: getAppBarHeight(screenSize),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: _buildResponsiveContent(screenSize),
      ),
    );
  }
}
```

## Responsive Design

### Mobile-First Breakpoint Strategy
- **Compact**: < 600dp (phones) - **Primary target**, design here first
- **Medium**: 600-959dp (tablets, foldables) - Enhance mobile design
- **Expanded**: ≥ 960dp (desktop) - Further enhancements while preserving mobile patterns

We follow a mobile-first approach: start with compact layouts and progressively enhance for larger screens. Desktop layouts maintain mobile interaction patterns while adding visual refinements like improved spacing, typography scaling, and optimized component positioning.

### Implementation

```dart
Widget _buildResponsiveLayout(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  
  if (width < 600) {
    return Padding(
      padding: EdgeInsets.all(DesignTokens.spacing16),
      child: _buildContent(),
    );
  } else if (width < 960) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacing24),
          child: _buildContent(),
        ),
      ),
    );
  } else {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacing32),
          child: _buildContent(),
        ),
      ),
    );
  }
}
```

## Material Design 3 Responsive Guidelines

### Screen Size Detection
```dart
enum ScreenSize {
  compact,  // < 600dp
  medium,   // 600-959dp  
  expanded  // ≥ 960dp
}

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return ScreenSize.compact;
  if (width < 960) return ScreenSize.medium;
  return ScreenSize.expanded;
}
```

### Component Sizing by Breakpoint

#### Typography Scaling
```dart
// Responsive text sizing with theme
TextStyle getHeadlineStyle(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return DesignTokens.headlineSmall;     // 24sp
    case ScreenSize.medium:
      return DesignTokens.headlineMedium;    // 28sp
    case ScreenSize.expanded:
      return DesignTokens.headlineLarge;     // 32sp
  }
}

// Primary header display text scaling (main page titles)
TextStyle getDisplayStyle(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return DesignTokens.displayMedium;     // 45sp
    case ScreenSize.medium:
    case ScreenSize.expanded:
      return DesignTokens.displayLarge;      // 57sp
  }
}

TextStyle getBodyStyle(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return DesignTokens.bodyMedium;        // 14sp
    case ScreenSize.medium:
    case ScreenSize.expanded:
      return DesignTokens.bodyLarge;         // 16sp
  }
}

TextStyle getLabelStyle(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return DesignTokens.labelMedium;       // 12sp
    case ScreenSize.medium:
    case ScreenSize.expanded:
      return DesignTokens.labelLarge;        // 14sp
  }
}
```

#### Component Dimensions
```dart
// Touch targets and spacing per breakpoint
double getTouchTarget(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
    case ScreenSize.medium:
      return 48.0;  // Mobile/tablet touch
    case ScreenSize.expanded:
      return 44.0;  // Desktop mouse/trackpad
  }
}

// Button width and positioning per breakpoint
Widget getResponsiveButton({required ScreenSize size, required String label, required VoidCallback onPressed}) {
  switch (size) {
    case ScreenSize.compact:
      // Full-width button for mobile
      return SizedBox(
        width: double.infinity,
        height: 48.0,
        child: FilledButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      );
    case ScreenSize.medium:
    case ScreenSize.expanded:
      // Content-based width with minimum constraints, right-aligned for tablet/desktop
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: size == ScreenSize.medium ? 120.0 : 140.0,  // Material Design minimum widths
            minHeight: size == ScreenSize.expanded ? 44.0 : 48.0,
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing24,  // 24dp horizontal padding for content-based sizing
                vertical: DesignTokens.spacing12,
              ),
            ),
            child: Text(label),
          ),
        ),
      );
  }
}

double getContentPadding(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return DesignTokens.spacing16;  // 16dp
    case ScreenSize.medium:
      return DesignTokens.spacing24;  // 24dp
    case ScreenSize.expanded:
      return DesignTokens.spacing32;  // 32dp
  }
}

double getFieldSpacing(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact:
      return DesignTokens.spacing16;  // 16dp between fields
    case ScreenSize.medium:
    case ScreenSize.expanded:
      return DesignTokens.spacing24;  // 24dp between fields
  }
}
```

### Form Layout by Breakpoint

#### Compact Layout (< 600dp) - Mobile (Primary Design Target)
```dart
Widget buildCompactForm(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(DesignTokens.spacing16),
    child: Column(
      children: [
        // Full-width text field
        TextFormField(
          style: DesignTokens.bodyMedium,  // 14sp for mobile
          decoration: InputDecoration(
            labelText: 'Label',
            labelStyle: DesignTokens.labelMedium,  // 12sp
            helperStyle: DesignTokens.bodySmall,   // 12sp
            contentPadding: EdgeInsets.all(DesignTokens.spacing16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
          ),
        ),
        SizedBox(height: DesignTokens.spacing16),  // 16dp spacing
        // Full-width button with 48dp height
        SizedBox(
          width: double.infinity,
          height: 48,  // Touch target for mobile
          child: FilledButton(
            onPressed: () {},
            child: Text('Submit', style: DesignTokens.labelMedium),
          ),
        ),
      ],
    ),
  );
}
```

#### Medium Layout (600-959dp) - Tablet (Enhanced from Mobile)
```dart
Widget buildMediumForm(BuildContext context) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacing24),
        child: Column(
          children: [
            // Adaptive width text fields
            Row(
              children: [
                // Short field (180dp) for ZIP, age, etc.
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    style: DesignTokens.bodyLarge,  // 16sp for tablet
                    decoration: InputDecoration(
                      labelText: 'ZIP Code',
                      labelStyle: DesignTokens.labelLarge,  // 14sp
                      contentPadding: EdgeInsets.all(DesignTokens.spacing16),
                    ),
                  ),
                ),
                SizedBox(width: DesignTokens.spacing16),
                // Medium field (320dp) for email, phone
                Expanded(
                  child: TextFormField(
                    style: DesignTokens.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: DesignTokens.labelLarge,
                      contentPadding: EdgeInsets.all(DesignTokens.spacing16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing24),  // 24dp spacing
            // Button row with content-based sizing and right alignment
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 88, minHeight: 48),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing16,
                        vertical: DesignTokens.spacing12,
                      ),
                    ),
                    child: Text('Cancel', style: DesignTokens.labelLarge),
                  ),
                ),
                SizedBox(width: DesignTokens.spacing8),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 120, minHeight: 48),
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing24,
                        vertical: DesignTokens.spacing12,
                      ),
                    ),
                    child: Text('Submit', style: DesignTokens.labelLarge),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

#### Expanded Layout (≥ 960dp) - Desktop (Further Enhancement, Mobile Patterns Preserved)
```dart
Widget buildExpandedForm(BuildContext context) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 640),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large headline for desktop
            Text(
              'Form Title',
              style: DesignTokens.headlineLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: DesignTokens.spacing32),
            // Two-column layout for related fields
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    style: DesignTokens.bodyLarge,  // 16sp
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: DesignTokens.labelLarge,  // 14sp
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing16,
                        vertical: DesignTokens.spacing12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: DesignTokens.spacing24),
                Expanded(
                  child: TextFormField(
                    style: DesignTokens.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: DesignTokens.labelLarge,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing16,
                        vertical: DesignTokens.spacing12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing24),
            // Full-width field for long content
            TextFormField(
              style: DesignTokens.bodyLarge,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: DesignTokens.labelLarge,
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.all(DesignTokens.spacing16),
              ),
            ),
            SizedBox(height: DesignTokens.spacing32),
            // Action buttons with content-based sizing and right alignment
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 88, minHeight: 44),  // Desktop minimum
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing20,
                        vertical: DesignTokens.spacing12,
                      ),
                    ),
                    child: Text('Cancel', style: DesignTokens.labelLarge),
                  ),
                ),
                SizedBox(width: DesignTokens.spacing12),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 140, minHeight: 44),  // Desktop minimum for primary button
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing24,
                        vertical: DesignTokens.spacing12,
                      ),
                    ),
                    child: Text('Submit', style: DesignTokens.labelLarge),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Complete Responsive Page Implementation
```dart
class ResponsivePageWithEdgeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Header: Edge-to-edge, responsive internal spacing
          buildResponsiveHeader(
            screenSize: screenSize, 
            title: 'Feedback Template',
          ),
          
          // Content: Constrained to form breakpoints
          Expanded(
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  switch (screenSize) {
                    case ScreenSize.compact:
                      return buildCompactForm(context);
                    case ScreenSize.medium:
                      return buildMediumForm(context);
                    case ScreenSize.expanded:
                      return buildExpandedForm(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsivePageWithAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Page Title',
          style: screenSize == ScreenSize.compact 
            ? DesignTokens.titleLarge      // 22sp on mobile
            : DesignTokens.headlineSmall,  // 24sp on tablet/desktop
        ),
        toolbarHeight: getAppBarHeight(screenSize),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            switch (screenSize) {
              case ScreenSize.compact:
                return buildCompactForm(context);
              case ScreenSize.medium:
                return buildMediumForm(context);
              case ScreenSize.expanded:
                return buildExpandedForm(context);
            }
          },
        ),
      ),
    );
  }
}
```


### Page Header Responsive Scaling

Headers should extend to the full edge of the page (edge-to-edge) while content inside adapts to screen size with responsive typography and spacing:

```dart
Widget buildResponsiveHeader({required ScreenSize screenSize, required String title}) {
  return Container(
    width: double.infinity,  // Always full width, edge-to-edge
    color: Theme.of(context).colorScheme.primary,
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _getHeaderHorizontalPadding(screenSize),
          vertical: _getHeaderVerticalPadding(screenSize),
        ),
        child: Column(
          children: [
            // Template icon/image with responsive sizing
            Container(
              width: _getHeaderIconSize(screenSize),
              height: _getHeaderIconSize(screenSize),
              decoration: BoxDecoration(
                color: Colors.yellow,  // Template-specific color
                borderRadius: BorderRadius.circular(_getHeaderIconSize(screenSize) / 2),
              ),
              child: Icon(
                Icons.favorite, 
                size: _getHeaderIconSize(screenSize) * 0.4,  // 40% of container size
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: DesignTokens.spacing24),
            // Responsive header text - same content, different typography
            Text(
              title,  // Content stays the same across all screen sizes
              style: getDisplayStyle(screenSize).copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,  // Allow wrapping for longer titles
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

// Header spacing functions - separate from form content breakpoints
double _getHeaderHorizontalPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:
      return DesignTokens.spacing20;   // 20dp mobile
    case ScreenSize.medium:
      return DesignTokens.spacing32;   // 32dp tablet
    case ScreenSize.expanded:
      return DesignTokens.spacing48;   // 48dp desktop
  }
}

double _getHeaderVerticalPadding(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:
      return DesignTokens.spacing32;   // 32dp mobile
    case ScreenSize.medium:
      return DesignTokens.spacing40;   // 40dp tablet
    case ScreenSize.expanded:
      return DesignTokens.spacing48;   // 48dp desktop
  }
}

double _getHeaderIconSize(ScreenSize screenSize) {
  switch (screenSize) {
    case ScreenSize.compact:
      return 80.0;   // 80dp mobile
    case ScreenSize.medium:
      return 100.0;  // 100dp tablet
    case ScreenSize.expanded:
      return 120.0;  // 120dp desktop
  }
}
```

### Header vs Content Breakpoint Strategy

**Key Principle**: Headers extend edge-to-edge while content respects breakpoint constraints.

```dart
class ResponsivePageWithHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Header: Edge-to-edge, responsive padding
          buildResponsiveHeader(screenSize: screenSize, title: 'Page Title'),
          
          // Content: Constrained to breakpoints
          Expanded(
            child: SafeArea(
              child: _buildConstrainedContent(screenSize),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConstrainedContent(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        // Full-width with padding for mobile
        return Padding(
          padding: EdgeInsets.all(DesignTokens.spacing16),
          child: _buildContent(),
        );
      case ScreenSize.medium:
        // Centered with max width constraint for tablet
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520),  // Form breakpoint
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.spacing24),
              child: _buildContent(),
            ),
          ),
        );
      case ScreenSize.expanded:
        // Centered with max width constraint for desktop
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640),  // Form breakpoint
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.spacing32),
              child: _buildContent(),
            ),
          ),
        );
    }
  }
}
```
```

### Material Design 3 Best Practices

#### Field Width Guidelines
```dart
enum FieldType { short, medium, long, full }

double getFieldWidth(ScreenSize size, FieldType type) {
  if (size == ScreenSize.compact) {
    return double.infinity;  // Always full width on mobile
  }
  
  switch (type) {
    case FieldType.short:   // ZIP code, age, quantity
      return 180;
    case FieldType.medium:  // Email, phone, name
      return 320;
    case FieldType.long:    // Address, URL
      return size == ScreenSize.expanded ? 480 : double.infinity;
    case FieldType.full:    // Description, comments
      return double.infinity;
  }
}
```

#### Validation and Error States
```dart
Widget buildResponsiveTextField({
  required BuildContext context,
  required String label,
  String? error,
  FieldType type = FieldType.medium,
}) {
  final screenSize = getScreenSize(context);
  
  return SizedBox(
    width: getFieldWidth(screenSize, type),
    child: TextFormField(
      style: getBodyStyle(screenSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: getLabelStyle(screenSize),
        errorText: error,
        errorStyle: DesignTokens.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
        helperStyle: DesignTokens.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        contentPadding: EdgeInsets.all(
          screenSize == ScreenSize.compact 
            ? DesignTokens.spacing12 
            : DesignTokens.spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
    ),
  );
}
```

#### Button Sizing and Spacing
```dart
Widget buildResponsiveButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  bool isPrimary = true,
}) {
  final screenSize = getScreenSize(context);
  final minHeight = getTouchTarget(screenSize);
  
  if (screenSize == ScreenSize.compact) {
    // Full-width button for mobile
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, minHeight),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing12,
          ),
        ),
        child: Text(label, style: getLabelStyle(screenSize)),
      ),
    );
  } else {
    // Content-based sizing with minimum constraints, right-aligned for tablet/desktop
    if (isPrimary) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenSize == ScreenSize.medium ? 120.0 : 140.0,
            minHeight: minHeight,
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing24,
                vertical: DesignTokens.spacing12,
              ),
            ),
            child: Text(label, style: getLabelStyle(screenSize)),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 88.0,
            minHeight: minHeight,
          ),
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize == ScreenSize.expanded 
                  ? DesignTokens.spacing20 
                  : DesignTokens.spacing16,
                vertical: DesignTokens.spacing12,
              ),
            ),
            child: Text(label, style: getLabelStyle(screenSize)),
          ),
        ),
      );
    }
  }
}



## Quick Checklist

### Design Token & Theme Setup
- [ ] Extract Figma design tokens using MCP server (`#fig` shortcut)
- [ ] Map all Figma variables to theme (never hardcode colors/fonts/sizes)
- [ ] Use theme values exclusively via Theme.of(context) or DesignTokens
- [ ] Verify Material Design 3 typography scale mapping (Display/Headline/Title/Body/Label)

### Page Structure & Layout
- [ ] Create page file in appropriate directory
- [ ] Implement responsive breakpoints (compact < 600dp, medium 600-959dp, expanded ≥ 960dp)
- [ ] Configure edge-to-edge header that extends to full page width
- [ ] Separate header spacing from content breakpoint constraints
- [ ] Choose appropriate form width based on type (simple: 520/640dp, template: 960dp with single column medium, two-column expanded)
- [ ] Follow 8dp grid system for all spacing and alignment

### Typography & Accessibility
- [ ] Configure responsive header with display typography scaling (Display Medium 45sp mobile, Display Large 57sp tablet/desktop)
- [ ] Implement responsive header icon sizing (80dp mobile, 100dp tablet, 120dp desktop)
- [ ] Use semantic typography (Display for heroes, Headline for titles, Body for content)
- [ ] Ensure WCAG AA contrast ratios using theme colors
- [ ] Test typography scaling across all screen sizes

### Component Sizing
- [ ] Maintain 48dp minimum touch targets for mobile accessibility
- [ ] Implement responsive component heights (buttons: 48dp mobile/tablet, 44dp desktop)
- [ ] Use correct Material Design 3 component dimensions (text fields: 56dp mobile, 48dp desktop)
- [ ] Apply proper component padding based on screen size

### Button Implementation
- [ ] Implement responsive button positioning (full-width mobile, content-based with minimum width constraints right-aligned tablet/desktop)
- [ ] Apply minimum width constraints based on Material Design guidelines (120dp medium, 140dp expanded for primary buttons)
- [ ] Use correct button heights and padding for each breakpoint
- [ ] Apply Material 3 button styling with DesignTokens.labelLarge text
- [ ] Ensure buttons size to content with proper padding (24dp horizontal) for medium/expanded screens

### Mobile Scrolling Architecture
- [ ] Choose CustomScrollView + Slivers for pages with titles or dynamic content
- [ ] Add `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())` for mobile-optimized scrolling
- [ ] Use `SliverPadding` for titles that scroll with content, aligned with card content
- [ ] Use `SliverFillRemaining` for loading/error/empty states instead of Center widgets
- [ ] Use `SliverList` instead of `ListView.builder` within CustomScrollView
- [ ] Avoid Column + Expanded + ListView anti-pattern
- [ ] Add bottom padding that includes system UI safe area
- [ ] Test scroll behavior across different content lengths and screen sizes

### Testing & Validation
- [ ] Test all breakpoints and component responsiveness
- [ ] Verify touch targets meet accessibility requirements
- [ ] Test in both light and dark themes (default to dark theme)
- [ ] Add page route to navigation
- [ ] Run flutter format and flutter analyze