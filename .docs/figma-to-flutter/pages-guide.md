# Creating Pages (Full Screens)

*As a Flutter frontend engineer, you are building production-quality pages that will be used in a professional app.*

Pages are primarily layout containers that compose existing organisms/molecules, but they must also handle responsive design, loading states, and error conditions properly.

## Flutter Engineering Standards for Pages

### Responsive Design Requirements
- Use **proper Material 3 breakpoints**: 600dp (compact→medium), 840dp (medium→expanded)
- Implement **adaptive navigation** (BottomNav mobile, NavigationRail desktop)
- **Constrain content width** on large screens (typically 1200px max)
- Use **LayoutBuilder** for context-aware responsive logic

### Required Page Features
- **Loading states** - Show progress indicators during async operations
- **Error handling** - Graceful error states with retry functionality
- **Empty states** - Meaningful feedback when no content exists
- **Safe scrolling** - Use SafeArea and proper scroll physics

## Page Architecture Patterns

### Pattern 1: Form/Content Page

**Key Structure:**
```dart
class MyFormScreen extends StatelessWidget {
  static const String routeName = '/my-form';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Title')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => _buildResponsiveLayout(constraints),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    
    // Material 3 breakpoint system
    if (width < 600) return YourFormWidget();           // Compact: full width
    if (width < 840) return _constrainedLayout(600);    // Medium: constrained
    return _constrainedLayout(800);                     // Expanded: wider constraint
  }

  Widget _constrainedLayout(double maxWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: maxWidth > 600 ? 32 : 24),
          child: YourFormWidget(),
        ),
      ),
    );
  }
}
```

**Critical Concepts:**
- Use `LayoutBuilder` for responsive decisions
- Apply proper constraints at each breakpoint
- Scale padding with screen size

### Pattern 2: List Page with State Management

**Key Structure:**
```dart
class MyListScreen extends StatefulWidget {
  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  bool _isLoading = true;
  String? _error;
  List<T> _items = [];

  Widget _buildContent(BoxConstraints constraints) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildErrorState();
    if (_items.isEmpty) return _buildEmptyState();
    
    return _buildResponsiveList(constraints.maxWidth);
  }

  Widget _buildResponsiveList(double width) {
    return width < 600 
        ? YourListWidget(items: _items)
        : Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: YourListWidget(items: _items),
          ));
  }
}
```

**Critical Concepts:**
- Always handle loading/error/empty states
- Use `mounted` checks before `setState`
- Constrain list width on larger screens
- Implement proper retry mechanisms

### Pattern 3: Dashboard/Grid Layout

**Key Structure:**
```dart
class DashboardScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: _getResponsivePadding(constraints.maxWidth),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDashboardContent(constraints),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(double width) {
    int crossAxisCount = width < 600 ? 1 : (width < 840 ? 2 : 3);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => YourGridItem(index),
    );
  }
}
```

**Critical Concepts:**
- Use `CustomScrollView` with `Slivers` for performance
- Calculate grid columns based on width breakpoints
- Use `shrinkWrap: true` and `NeverScrollableScrollPhysics()` for nested scrollables

## Engineering Principles

### 1. Responsive Architecture
- **LayoutBuilder** - Always use for context-aware responsive decisions
- **Material 3 breakpoints** - 600dp (compact→medium), 840dp (medium→expanded)
- **Content constraints** - Prevent text/content stretching on large screens
- **Scaling patterns** - Adjust padding, spacing, and sizes per breakpoint

### 2. State Management
- **Loading states** - CircularProgressIndicator during async operations
- **Error recovery** - Retry buttons with proper error messaging
- **Empty states** - Meaningful guidance when no content exists
- **Memory safety** - `mounted` checks before `setState` calls

### 3. Performance Standards
- **Efficient scrolling** - CustomScrollView/Slivers for complex content
- **Lazy loading** - ListView.builder for large datasets
- **Const constructors** - Prevent unnecessary widget rebuilds
- **Resource cleanup** - Dispose controllers, cancel futures in dispose()

### 4. Professional Requirements
- **Material 3 compliance** - Proper elevation, color schemes, spacing
- **Accessibility support** - Semantic labels, touch targets (44dp min)
- **Error handling** - try/catch with user-friendly error messages
- **Code organization** - Separate layout logic into private methods

## Page Architecture Checklist

**Structure Requirements:**
- [ ] `LayoutBuilder` for responsive behavior
- [ ] Material 3 breakpoints (600dp, 840dp)
- [ ] Loading/error/empty state handling
- [ ] `SafeArea` around scrollable content
- [ ] Content width constraints on large screens

**Code Quality:**
- [ ] Private methods for layout logic separation
- [ ] `const` constructors where applicable
- [ ] `try/catch` error handling
- [ ] `mounted` checks before `setState`
- [ ] Proper Flutter/Dart naming conventions

**Performance:**
- [ ] `CustomScrollView`/`ListView.builder` for efficient scrolling
- [ ] Minimal rebuilds (const constructors)
- [ ] Resource disposal (`dispose()` method)
- [ ] `RepaintBoundary` for expensive widgets

**Accessibility:**
- [ ] Semantic labels for screen readers
- [ ] 44dp minimum touch targets
- [ ] High contrast and large text support
- [ ] TalkBack/VoiceOver testing