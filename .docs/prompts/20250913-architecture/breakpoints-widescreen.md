Apply Material Design 3 responsive breakpoints to the create session page following the same pattern implemented in the login screen.

  Requirements:

  1. Implement MD3 breakpoint system:
    - < 600px: Compact layout (single column, full width)
    - 600-840px: Medium layout (single column, constrained to 600px width)
    - 840-1200px: Expanded layout (2-column if beneficial, otherwise optimized single column)
    - ≥ 1200px: Enhanced layout (wider spacing, larger typography, improved proportions)
  2. Use existing responsive utilities:
    - Follow the _buildResponsiveLayout() pattern from login_screen.dart:142-149
    - Use DesignTokens spacing and typography constants
    - Implement LayoutBuilder with BoxConstraints for width detection
  3. Consider form complexity:
    - If form has multiple sections → 2-column layout at ≥840px (form left, helper content right)
    - If single form → enhanced single column with better spacing and typography
    - Maintain proper form field grouping and visual hierarchy
  4. Enhancement breakpoint (≥1200px):
    - Increase max container width (1200px → 1400px)
    - Add generous horizontal padding (spacing48 or spacing64)
    - Scale up typography (larger titles, enhanced body text)
    - Improve spacing between form elements
  5. Preserve existing functionality:
    - Keep all form validation and submission logic intact
    - Maintain scroll behavior and keyboard handling
    - Ensure mobile-first responsive design principles

  Files to examine:
  - lib/features/sessions/screens/session_create_screen.dart
  - Reference lib/features/auth/screens/login_screen.dart for responsive patterns
  - Use lib/core/themes/design_tokens.dart for consistent spacing/typography

  Apply the same responsive design principles we successfully implemented in the login screen to create a cohesive, Material Design 3 compliant experience across the session creation flow.
