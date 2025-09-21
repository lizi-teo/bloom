# Theme Mapping: Figma to Flutter

**You are a Flutter frontend engineer building production-quality mobile and web applications. This guide ensures consistent design system implementation across all platforms.**

## CRITICAL: Flutter Theme Architecture

### DesignTokens are Translation Layer ONLY

DesignTokens exist solely to map Figma designs to Flutter Theme. **All UI components must use Flutter Theme.**

**Proper Architecture Flow:**
```
Figma Design → DesignTokens → Flutter Theme → UI Components
```

### ✅ ALWAYS Use Flutter Theme in UI Components
```dart
// ✅ PRODUCTION STANDARD: All UI components use Flutter Theme
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineLarge,    // Theme-aware typography
),
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,      // Theme-aware colors
  ),
  child: ElevatedButton(                                // Material components inherit theme
    onPressed: () {},
    child: Text('Action'),
  ),
),
```

### ❌ ARCHITECTURE VIOLATION: Direct DesignTokens in UI
```dart
// ❌ NEVER: Bypasses Flutter Theme system
Text(
  'Welcome',
  style: DesignTokens.headlineLarge,                   // Breaks theme-aware styling
),
Container(
  padding: EdgeInsets.all(DesignTokens.spacing16),    // Should use theme spacing
  decoration: BoxDecoration(
    color: DesignTokens.lightSurface,                  // Hardcoded theme coupling
  ),
),
```

**DesignTokens should ONLY be used in:**
- `/lib/core/themes/design_tokens.dart` - Source definitions
- `/lib/core/themes/app_theme.dart` - Populating Flutter Theme

## Production Workflow

### 1. Extract Design Specifications from Figma
```bash
# Use #fig shortcut to run comprehensive Figma analysis:
# - get_variable_defs (design tokens and color variables)
# - get_code (component implementation reference)
# - get_image (visual specification for validation)
```

### 2. Map to Flutter Theme System
**MANDATORY: Only use Flutter Theme in UI components**

This ensures:
- Consistent visual language across all screens
- Automatic dark/light theme support
- Maintainable design system evolution
- Accessibility compliance

## Color Mapping Standards

### Production Color Implementation
```dart
// Figma Design Variables → Flutter Theme Implementation
M3/Light/*    → DesignTokens.light*    // Light theme color scheme
M3/Dark/*     → DesignTokens.dark*     // Dark theme color scheme  
M3/Pink-DT/*  → DesignTokens.pinkDark* // Brand-specific color variants

// ✅ PRODUCTION STANDARD: Always use theme context
Theme.of(context).colorScheme.primary      // Primary brand color
Theme.of(context).colorScheme.surface      // Background surfaces
Theme.of(context).colorScheme.onSurface    // Text/icons on surfaces
Theme.of(context).colorScheme.secondary    // Secondary actions
Theme.of(context).colorScheme.error        // Error states

// ❌ PRODUCTION VIOLATION: Never hardcode colors
Color(0xFF123456)  // Breaks theme switching, accessibility
Colors.blue        // Breaks design system consistency
```

**Why this matters in production:**
- Ensures seamless dark/light theme transitions
- Maintains brand consistency across platforms
- Supports accessibility requirements (contrast ratios)
- Enables rapid design system updates

## Typography System Standards

### Material Design 3 Typography Scale
```dart
// Figma Typography Variables → Flutter Implementation (Material Design 3)
Static/Display-*   → DesignTokens.display*     // 57sp/45sp/36sp - Hero sections, landing pages
Static/Headline-*  → DesignTokens.headline*    // 32sp/28sp/24sp - Page titles, major sections  
Static/Title-*     → DesignTokens.title*       // 22sp/16sp/14sp - Card headers, list sections
Static/Body-*      → DesignTokens.body*        // 16sp/14sp/12sp - Content text, descriptions
Static/Label-*     → DesignTokens.label*       // 14sp/12sp/11sp - Buttons, tabs, form labels

// ✅ PRODUCTION STANDARD: Typography implementation
Theme.of(context).textTheme.headlineMedium    // Context-aware theming
Theme.of(context).textTheme.bodyLarge         // Always use theme
Theme.of(context).textTheme.labelMedium.copyWith(  // Styled variations
  color: Theme.of(context).colorScheme.primary,
)

// ❌ PRODUCTION VIOLATION: Hardcoded typography
TextStyle(fontSize: 16, fontWeight: FontWeight.w400)  // Breaks accessibility scaling
GoogleFonts.roboto(fontSize: 14)                      // Breaks design system consistency
```

**Production Typography Benefits:**
- Automatic accessibility scaling (user font size preferences)
- Consistent line heights and letter spacing
- Platform-appropriate font rendering
- Seamless design system evolution

## Spatial Design System

### Material Design 3 8dp Grid System
```dart
// Production Spacing Standards (8dp baseline grid)
DesignTokens.spacing4   // 4dp  - Micro adjustments, icon spacing
DesignTokens.spacing8   // 8dp  - Component internal padding
DesignTokens.spacing12  // 12dp - Small component gaps
DesignTokens.spacing16  // 16dp - Standard content padding
DesignTokens.spacing24  // 24dp - Section separation
DesignTokens.spacing32  // 32dp - Large content blocks
DesignTokens.spacing48  // 48dp - Major page sections

// Surface Design Standards
DesignTokens.radiusSmall   // 8dp  - Input fields, chips
DesignTokens.radiusMedium  // 12dp - Cards, dialogs
DesignTokens.radiusLarge   // 20dp - Bottom sheets, modals

// Elevation Hierarchy (Material Design 3)
DesignTokens.elevation0  // 0dp - Flat surfaces, backgrounds
DesignTokens.elevation1  // 1dp - Cards at rest state
DesignTokens.elevation2  // 3dp - Interactive card states
DesignTokens.elevation3  // 6dp - Overlays, menus, modals

// ✅ PRODUCTION STANDARD: Spatial implementation
// Note: For spacing, use theme-based approach or Material components when possible
Card(
  margin: EdgeInsets.all(16.0),  // Material components handle spacing
  child: Padding(
    padding: EdgeInsets.all(16.0),  // Standard Material padding
    child: Text(
      'Content',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  ),
)

// ❌ PRODUCTION VIOLATION: Hardcoded spatial values
EdgeInsets.all(16)             // Breaks responsive design
BorderRadius.circular(12)      // Breaks design consistency
SizedBox(height: 24)           // No relationship to design system
```

**Production Spatial Benefits:**
- Consistent visual rhythm across all platforms
- Responsive design that scales appropriately
- Simplified maintenance and design updates
- Accessibility-compliant touch targets

## Production Implementation Examples

### Example 1: Production Button Implementation
```dart
// ❌ NON-PRODUCTION: Direct Figma extraction (breaks design system)
Container(
  width: 120,
  height: 48,
  decoration: BoxDecoration(
    color: Color(0xFF6750A4),                    // Hardcoded color - breaks theming
    borderRadius: BorderRadius.circular(12),     // Hardcoded radius - breaks consistency
  ),
  child: Text(
    'Submit', 
    style: TextStyle(fontSize: 14, color: Colors.white),  // Hardcoded typography - breaks accessibility
  ),
)

// ✅ PRODUCTION STANDARD: Design system implementation
FilledButton(
  onPressed: () {},
  style: FilledButton.styleFrom(
    minimumSize: Size(120, 48),                                    // Maintains accessibility targets
    backgroundColor: Theme.of(context).colorScheme.primary,        // Theme-aware coloring
    foregroundColor: Theme.of(context).colorScheme.onPrimary,     // Proper contrast ratio
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),  // Consistent radius
    ),
  ),
  child: Text('Submit', style: Theme.of(context).textTheme.labelLarge),  // Theme typography
)
```

**Production Impact:**
- Automatic theme switching (light/dark mode)
- Accessibility compliance (WCAG contrast ratios)
- Consistent behavior across all app buttons
- Future-proof design system evolution

### Example 2: Production Card Implementation
```dart
// ❌ NON-PRODUCTION: Figma pixel-perfect extraction (fragile implementation)
Container(
  width: double.infinity,
  padding: EdgeInsets.all(16),                     // Hardcoded spacing - breaks responsive design
  decoration: BoxDecoration(
    color: Color(0xFF1C1B1F),                     // Hardcoded color - breaks theme switching
    borderRadius: BorderRadius.circular(12),       // Hardcoded radius - inconsistent surfaces
    boxShadow: [                                   // Custom shadow - breaks elevation system
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(0, 2),
      )
    ],
  ),
  child: Text(
    'Content', 
    style: TextStyle(fontSize: 14, color: Colors.white),  // Hardcoded text - accessibility issues
  ),
)

// ✅ PRODUCTION STANDARD: Material Design 3 Card system
Card(
  elevation: DesignTokens.elevation1,                      // Consistent elevation hierarchy
  color: Theme.of(context).colorScheme.surface,           // Theme-aware surface color
  surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,  // Material 3 surface tinting
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),  // Design system radius
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),                       // Material standard spacing
    child: Text(
      'Content',
      style: Theme.of(context).textTheme.bodyMedium,     // Theme typography with proper contrast
    ),
  ),
)
```

**Production Card Benefits:**
- Material 3 surface tinting and elevation system
- Proper semantic colors for accessibility
- Consistent with all other app cards
- Responsive padding that works across screen sizes

## Production Quality Standards

### Mandatory Design System Rules

1. **Color System**: ONLY `Theme.of(context).colorScheme.*` for all colors
2. **Typography System**: ONLY `Theme.of(context).textTheme.*` for text styles
3. **Spacing System**: Use Material Design standard spacing (8dp grid)
4. **Surface System**: Let Material components handle radius and elevation
5. **Component System**: Prefer Material 3 widgets over custom containers

### Production Readiness Checklist

Before marking any component complete:

**🎨 Design System Compliance**
- [ ] Zero hardcoded colors (`Color(0x...)`, `Colors.*` violations)
- [ ] Zero hardcoded typography (`fontSize:`, `fontWeight:` violations)
- [ ] Zero direct DesignTokens usage in UI components
- [ ] All text uses `Theme.of(context).textTheme.*`

**🌙 Theme System Integration**
- [ ] Component renders correctly in light theme
- [ ] Component renders correctly in dark theme
- [ ] All text maintains proper contrast ratios
- [ ] Interactive states (hover, pressed) use theme colors

**📱 Material Design 3 Standards**
- [ ] Uses Material 3 components when available (prefer `FilledButton` over custom containers)
- [ ] Proper elevation hierarchy maintained
- [ ] Surface tinting applied correctly
- [ ] Accessibility touch targets (44dp minimum) respected

**🔧 Production Performance**
- [ ] No unnecessary `Container` widgets where Material components exist
- [ ] Efficient theme access (minimal `Theme.of(context)` calls)
- [ ] Proper widget composition for reusability

This checklist ensures enterprise-grade Flutter development standards.

## Flutter Theme vs Design Tokens Architecture

### CRITICAL: DesignTokens are Translation Layer ONLY

DesignTokens exist solely to map Figma designs to Flutter Theme. **All UI components must use Flutter Theme.**

**Proper Architecture Flow:**
```
Figma Design → DesignTokens → Flutter Theme → UI Components
```

#### ✅ ONLY Valid DesignTokens Usage
```dart
// ONLY in /lib/core/themes/app_theme.dart - populating Flutter Theme
textTheme: TextTheme(
  headlineLarge: DesignTokens.headlineLarge.copyWith(color: colorScheme.onSurface),
  bodyMedium: DesignTokens.bodyMedium.copyWith(color: colorScheme.onSurface),
),
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: DesignTokens.buttonMediumPadding,  // Spatial constants
    elevation: DesignTokens.elevation1,         // Elevation constants
  ),
),
```

**DesignTokens should ONLY be used in:**
- `/lib/core/themes/design_tokens.dart` - Source definitions
- `/lib/core/themes/app_theme.dart` - Populating Flutter Theme

#### ✅ ALWAYS Use Flutter Theme in UI Components
```dart
// ✅ PRODUCTION STANDARD: All UI components use Flutter Theme
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineLarge,    // Theme-aware typography
),
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,      // Theme-aware colors
  ),
  child: ElevatedButton(                                // Material components inherit theme
    onPressed: () {},
    child: Text('Action'),
  ),
),
```

#### ❌ ARCHITECTURE VIOLATION: Direct DesignTokens in UI
```dart
// ❌ NEVER: Bypasses Flutter Theme system
Text(
  'Welcome', 
  style: DesignTokens.headlineLarge,                   // Breaks theme-aware styling
),
Container(
  padding: EdgeInsets.all(DesignTokens.spacing16),    // Should use theme spacing
  decoration: BoxDecoration(
    color: DesignTokens.lightSurface,                  // Hardcoded theme coupling
  ),
),
```

### Why This Architecture Matters

**Flutter Theme Benefits:**
- Automatic light/dark mode switching
- Semantic color relationships (surface/onSurface pairs)
- Material Design 3 integration
- User accessibility preferences (font scaling)
- Context-aware theming

**DesignTokens Role:**
- Bridge between Figma and Flutter
- Single source of truth for design values
- Populate Flutter Theme definitions
- NOT for direct UI consumption

### Key Benefits of This Architecture

**Flutter Theme Benefits:**
- Automatic light/dark mode switching
- Semantic color relationships (surface/onSurface pairs)
- Material Design 3 integration
- User accessibility preferences (font scaling)
- Context-aware theming

**DesignTokens Role:**
- Bridge between Figma and Flutter
- Single source of truth for design values
- Populate Flutter Theme definitions
- NOT for direct UI consumption