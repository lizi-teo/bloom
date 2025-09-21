# Production-Quality Flutter Component Validation Checklist

**You are a Flutter frontend engineer building production-quality components and pages for the Bloom application. This checklist ensures your implementations meet enterprise standards for maintainability, performance, accessibility, and user experience.**

**Complete this comprehensive validation before considering any component or page production-ready.**

## Theme Compliance (CRITICAL)

### Colors
- [ ] No hardcoded colors (`Color(0x...)`, `Colors.*`)
- [ ] All colors use `Theme.of(context).colorScheme.*`
- [ ] Component works in both light and dark themes

### Typography
- [ ] No hardcoded text styles (`fontSize:`, `fontWeight:`)
- [ ] Uses `DesignTokens.*` or `Theme.of(context).textTheme.*`
- [ ] Proper semantic typography (Display/Headline/Title/Body/Label)

### Spacing & Layout
- [ ] No hardcoded spacing (raw numbers in `EdgeInsets`, `SizedBox`)
- [ ] Uses `DesignTokens.spacing*` throughout
- [ ] Uses `DesignTokens.radius*` for border radius
- [ ] Uses `DesignTokens.elevation*` for shadows

## Mobile Requirements (MANDATORY)

### SafeArea & Layout
- [ ] `SafeArea` wrapper around main content
- [ ] `resizeToAvoidBottomInset: true` for pages with text input
- [ ] Bottom spacing includes `MediaQuery.of(context).padding.bottom`
- [ ] No content cutoff by system UI (status bar, notch, navigation)

### Touch Targets
- [ ] Interactive elements minimum 48dp on mobile (44dp on desktop)
- [ ] Buttons have proper minimum size constraints
- [ ] Touch areas don't overlap or conflict

### Scrolling (For List Pages)
- [ ] Uses `CustomScrollView` with `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())`
- [ ] `SliverFillRemaining` for loading/error/empty states
- [ ] Title scrolls with content using `SliverPadding` + `SliverToBoxAdapter`
- [ ] Avoids Column + Expanded + ListView anti-pattern

## Responsive Design (For Organisms & Pages)

### Breakpoint Implementation
- [ ] Compact (< 600dp): Mobile-optimized layout
- [ ] Medium (600-959dp): Enhanced tablet layout
- [ ] Expanded (≥ 960dp): Desktop refinements

### Component Sizing
- [ ] Mobile: Full-width buttons
- [ ] Tablet/Desktop: Content-based buttons with right alignment
- [ ] Responsive padding and spacing helpers implemented
- [ ] Typography scales appropriately across breakpoints

## Component Architecture

### For Atoms
- [ ] Uses Material 3 components when possible
- [ ] Checks existing atoms/molecules before creating new ones
- [ ] Handles disabled/loading states appropriately
- [ ] Single responsibility, reusable design

### For Organisms
- [ ] Composes existing molecules and atoms
- [ ] Mobile-first responsive design
- [ ] Proper state management
- [ ] Clear props interface

### For Pages
- [ ] Uses appropriate page template (Header vs AppBar)
- [ ] Implements all three responsive breakpoints
- [ ] Handles loading, error, and empty states
- [ ] Proper route name defined
- [ ] Navigation integration complete

## Code Quality

### Structure
- [ ] File in correct directory (`lib/atoms/`, `lib/organisms/`, `lib/features/*/screens/`)
- [ ] Proper imports and exports
- [ ] Clear, descriptive naming
- [ ] No unused imports or variables

### State Management
- [ ] Uses appropriate state management (Provider, Riverpod, BLoC) - no raw setState for complex state
- [ ] Loading states with proper UI feedback (CircularProgressIndicator, skeleton screens)
- [ ] Comprehensive error handling with user-friendly messages and recovery options
- [ ] Input validation with real-time feedback and proper error states
- [ ] State persistence considerations for user experience

### Performance
- [ ] No expensive operations in build method
- [ ] Proper use of const constructors
- [ ] Efficient list rendering (SliverList vs ListView)
- [ ] No memory leaks (dispose controllers, listeners)

## Accessibility & Inclusive Design (WCAG 2.1 AA)

### Screen Reader Support
- [ ] Meaningful semantic labels for all interactive elements
- [ ] Proper heading hierarchy (H1, H2, H3) implemented
- [ ] Form fields have associated labels and error announcements
- [ ] Loading states announced to assistive technology
- [ ] Focus management for modal dialogs and navigation

### Visual Accessibility
- [ ] Color contrast ratios meet WCAG AA standards (4.5:1 normal, 3:1 large text)
- [ ] Information conveyed without relying solely on color
- [ ] Text scalability up to 200% without horizontal scrolling
- [ ] Focus indicators clearly visible and high contrast

### Motor Accessibility
- [ ] Touch targets minimum 44dp (iOS) / 48dp (Android) with adequate spacing
- [ ] Keyboard navigation fully functional
- [ ] No time-sensitive interactions without user control
- [ ] Gestures have alternative input methods

## Testing Verification

### Cross-Platform Validation
- [ ] iOS: Native look and feel, proper safe area handling
- [ ] Android: Material Design 3 compliance, edge-to-edge support
- [ ] Web: Responsive design, keyboard navigation, browser compatibility
- [ ] Works correctly across light/dark themes with proper contrast

### Performance Testing
- [ ] Component renders in < 16ms (60fps) under normal conditions
- [ ] Large lists use virtualization (ListView.builder, SliverList)
- [ ] Images optimized and cached appropriately
- [ ] No memory leaks during navigation or state changes
- [ ] Smooth animations without jank (use Flutter Inspector)

### Error Boundary Testing
- [ ] Graceful handling of network failures
- [ ] Proper fallbacks for missing or invalid data
- [ ] Error states provide clear next steps for users
- [ ] Form validation prevents invalid submissions
- [ ] Offline functionality where applicable

## Enterprise Readiness

### Code Quality Standards
- [ ] Figma design specifications implemented with pixel-perfect accuracy
- [ ] Comprehensive error handling and loading states
- [ ] Production-ready state management (no setState for complex logic)
- [ ] Proper separation of concerns (UI, business logic, data)
- [ ] Type safety throughout (no dynamic types without justification)

### Documentation & Maintainability
- [ ] Component API documented with usage examples and props
- [ ] Complex business logic includes inline documentation
- [ ] Error scenarios documented with expected behaviors
- [ ] Integration points clearly defined and tested

### Security & Data Handling
- [ ] Sensitive data not logged or exposed in debug output
- [ ] Input sanitization for user-generated content
- [ ] Proper handling of authentication states
- [ ] Data validation both client and server-side

### Production Deployment Checklist
- [ ] `flutter analyze` passes with zero warnings
- [ ] `flutter test` passes with comprehensive coverage
- [ ] Performance profiling shows acceptable metrics
- [ ] No TODO comments or development-only code
- [ ] Feature flags configured for gradual rollout (if applicable)
- [ ] Monitoring and analytics integration complete

---

**If any item is unchecked, address it before considering the component/page complete.**