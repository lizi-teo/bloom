# Figma Design Token Extraction Guide

This guide will help you manually extract Material Design 3 tokens from your Figma design file and populate the Flutter theme system.

## 🔄 Token Extraction Process

### Step 1: Access Your Figma Design
1. Open the Figma design file: https://www.figma.com/design/FANPhQeO5FKEIp6SUsWGd3/Facilitation-app?node-id=59796-12448&t=AQRFAquI6gh5boqv-1
2. Navigate to the design system or styles section
3. Look for color styles, text styles, and component specifications

### Step 2: Extract Color Tokens

#### In Figma:
1. Go to the **Styles** panel (usually on the right sidebar)
2. Look for **Color Styles** organized by Material Design 3 naming
3. For each color, note down:
   - Color name (e.g., "Primary", "Primary Container")
   - Hex value (e.g., #6750A4)
   - Theme mode (Light, Dark, Pink Dark)

#### Expected Color Categories:
- **Primary Colors**: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`
- **Secondary Colors**: `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`
- **Tertiary Colors**: `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`
- **Error Colors**: `error`, `onError`, `errorContainer`, `onErrorContainer`
- **Surface Colors**: `background`, `onBackground`, `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`
- **Outline Colors**: `outline`, `outlineVariant`

#### Update the Flutter Code:
Replace the placeholder values in `/Users/lizzieteo/Development/bloom-app/lib/theme/design_tokens.dart`:

```dart
// LIGHT THEME COLORS - Replace with actual Figma values
static const Color lightPrimary = Color(0xFF6750A4); // ← Replace this hex value
static const Color lightOnPrimary = Color(0xFFFFFFFF); // ← Replace this hex value
// ... continue for all colors
```

### Step 3: Extract Typography Tokens

#### In Figma:
1. Go to the **Text Styles** panel
2. Look for Material Design 3 typography scale:
   - Display Large/Medium/Small
   - Headline Large/Medium/Small  
   - Title Large/Medium/Small
   - Body Large/Medium/Small
   - Label Large/Medium/Small

#### For each text style, note:
- Font family (e.g., "Roboto", "Inter")
- Font size (e.g., 57px, 24px)
- Font weight (e.g., Regular/400, Medium/500)
- Line height (e.g., 64px or 1.12)
- Letter spacing (e.g., -0.25px)

#### Update Typography in design_tokens.dart:
```dart
static const String primaryFontFamily = 'YourFontFamily'; // ← Replace
static const TextStyle displayLarge = TextStyle(
  fontSize: 57, // ← Replace with Figma value
  fontWeight: FontWeight.w400, // ← Replace with Figma value
  letterSpacing: -0.25, // ← Replace with Figma value
  height: 1.12, // ← Replace with Figma value
);
```

### Step 4: Extract Spacing & Layout Tokens

#### In Figma:
1. Inspect components and layouts
2. Look for consistent spacing patterns
3. Note border radius values on buttons, cards, inputs
4. Check elevation/shadow values

#### Common spacing patterns to look for:
- 4px, 8px, 12px, 16px, 20px, 24px, 32px, 40px, 48px, 64px

#### Update Spacing in design_tokens.dart:
```dart
static const double spacing8 = 8.0; // ← Confirm or replace values
static const double radiusMedium = 12.0; // ← Replace with Figma values
```

### Step 5: Extract Component-Specific Tokens

#### Check these components in Figma:
- **Buttons**: Background colors, border radius, padding, text styles
- **Cards**: Background color, elevation, border radius, padding
- **Input fields**: Border styles, fill colors, padding, text styles
- **App bars**: Background colors, elevation, text styles

## 🛠️ Implementation Steps

### 1. Update Design Tokens
Edit `/Users/lizzieteo/Development/bloom-app/lib/theme/design_tokens.dart` with your extracted values.

### 2. Test Your Theme
Run the example app to preview your theme:

```dart
// In your main.dart, replace the existing app with:
import 'theme/theme_example.dart';

void main() {
  runApp(const ThemedApp());
}
```

### 3. Verify All Three Theme Variants
Make sure you extract values for:
- ✅ Light theme
- ✅ Dark theme  
- ✅ Pink dark theme (if it exists in your design)

## 📋 Extraction Checklist

### Colors (Most Important):
- [ ] Light theme: Primary colors (4 variants)
- [ ] Light theme: Secondary colors (4 variants)
- [ ] Light theme: Tertiary colors (4 variants)
- [ ] Light theme: Error colors (4 variants)
- [ ] Light theme: Surface colors (6 variants)
- [ ] Light theme: Outline colors (2 variants)
- [ ] Dark theme: All color categories (same as light)
- [ ] Pink dark theme: All color categories (if present)

### Typography:
- [ ] Primary font family
- [ ] Display styles (Large, Medium, Small)
- [ ] Headline styles (Large, Medium, Small)
- [ ] Title styles (Large, Medium, Small)
- [ ] Body styles (Large, Medium, Small)
- [ ] Label styles (Large, Medium, Small)

### Spacing & Layout:
- [ ] Spacing scale (4px to 64px)
- [ ] Border radius values
- [ ] Elevation values

### Components:
- [ ] Button styles and properties
- [ ] Card styles and properties
- [ ] Input field styles and properties
- [ ] Navigation styles and properties

## 🎨 Color Extraction Tips

1. **Use Figma's Inspector**: Select any element and check its fill color in the right panel
2. **Copy Hex Values**: Right-click on colors to copy hex values directly
3. **Check for Variables**: Look for design tokens/variables in Figma's design system
4. **Semantic Naming**: Focus on colors named with semantic meanings (primary, secondary, etc.) rather than literal colors (blue, red, etc.)

## 🚀 Usage After Extraction

Once you've populated all the tokens, your app will support:

```dart
// Easy theme switching
themeProvider.setTheme(ThemeVariant.light);
themeProvider.setTheme(ThemeVariant.dark);
themeProvider.setTheme(ThemeVariant.pinkDark);

// Accessing theme colors
context.colors.primary
context.colors.surface
context.textTheme.headlineLarge

// Using design tokens directly
Container(
  padding: EdgeInsets.all(DesignTokens.spacing16),
  decoration: BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
  ),
)
```

## 🔍 Troubleshooting

- **Missing colors?** Check if Figma has them organized in a different section or named differently
- **Pink dark theme not found?** It might not exist in your design - you can create it based on the dark theme
- **Typography looks different?** Double-check font weights and line heights - these are often the culprits
- **Spacing feels off?** Verify the spacing scale matches your design system's specifications

Remember: The goal is to create a comprehensive, maintainable theme system that accurately reflects your Figma design!