# Mobile Requirements (MANDATORY)

**You are a Flutter frontend engineer building production-quality mobile applications.** These patterns prevent mobile display cutoff, ensure proper UX, and maintain professional standards for mobile development. Every mobile page must implement these requirements to pass code review and deployment standards.

## 1. SafeArea Wrapper (REQUIRED)

```dart
// ✅ ALWAYS wrap Scaffold body content in SafeArea
Scaffold(
  body: SafeArea(  // REQUIRED - Prevents content cutoff by system UI
    child: CustomScrollView(
      // Your content here
    ),
  ),
)

// ❌ NEVER omit SafeArea
Scaffold(
  body: Column(  // Wrong! Content will be cut off by status bar/notch
    children: [...],
  ),
)
```

## 2. Keyboard Handling (REQUIRED for Input Pages)

```dart
// ✅ ALWAYS add keyboard avoidance for pages with text input
Scaffold(
  resizeToAvoidBottomInset: true,  // REQUIRED for text input pages
  body: SafeArea(
    child: // Your content
  ),
)
```

## 3. Bottom Content Spacing (REQUIRED)

```dart
// ✅ ALWAYS add system UI padding to bottom spacing in scroll views
SliverPadding(
  padding: EdgeInsets.only(
    bottom: DesignTokens.spacing48 + MediaQuery.of(context).padding.bottom
  ),
),

// For regular Column/ListView:
SizedBox(height: DesignTokens.spacing48 + MediaQuery.of(context).padding.bottom),
```

## 4. FloatingActionButton Positioning (If Used)

```dart
// ✅ ALWAYS add system UI padding to FloatingActionButtons
floatingActionButton: Padding(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom +  // Keyboard
            MediaQuery.of(context).padding.bottom,      // System navigation
  ),
  child: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
),
```

## 5. Mobile Scrolling Architecture (CRITICAL)

### Use CustomScrollView + Slivers for Better UX

```dart
// ✅ PRODUCTION: CustomScrollView with proper accessibility and performance
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(
    parent: BouncingScrollPhysics(), // Platform-appropriate physics
  ),
  semanticChildCount: items.length,
  slivers: [
    // Accessible title with proper semantic structure
    SliverPadding(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.spacing32,
        DesignTokens.spacing24,
        DesignTokens.spacing32,
        DesignTokens.spacing32,
      ),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          header: true,
          child: Text(
            context.l10n.pageTitle,
            style: DesignTokens.displaySmall,
          ),
        ),
      ),
    ),
    // Performance-optimized list with proper state management
    Consumer<DataNotifier>(
      builder: (context, notifier, child) => _buildContentSliver(),
    ),
    // System UI bottom padding
    SliverPadding(
      padding: EdgeInsets.only(
        bottom: DesignTokens.spacing48 + 
                MediaQuery.of(context).padding.bottom,
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

### When to Use Each Architecture

| Use Case | Architecture | Reason |
|----------|-------------|---------|
| Page with title + list | CustomScrollView + SliverPadding + SliverList | Title scrolls with content |
| Simple form | SingleChildScrollView | Static content, no dynamic lists |
| Loading/error states | CustomScrollView + SliverFillRemaining | Proper space filling |

## 6. Production Loading/Error States with State Management

```dart
class _PageState extends State<Page> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildContentSliver() {
    return Consumer<PageNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading && notifier.items.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    semanticsLabel: context.l10n.loadingData,
                  ),
                  SizedBox(height: DesignTokens.spacing16),
                  Text(
                    context.l10n.loadingMessage,
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (notifier.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: ErrorStateWidget(
                error: notifier.error,
                onRetry: notifier.retry,
                semanticsLabel: context.l10n.errorLoadingData,
              ),
            ),
          );
        }
        
        if (notifier.items.isEmpty) {
          return SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.folder_open_outlined,
              title: context.l10n.noDataTitle,
              description: context.l10n.noDataDescription,
              action: EmptyStateAction(
                label: context.l10n.createNew,
                onPressed: () => context.go('/create'),
              ),
            ),
          );
        }
        
        return _buildContentList(notifier.items, notifier.isLoadingMore);
      },
    );
  }

  Widget _buildContentList(List<Item> items, bool isLoadingMore) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == items.length) {
            return isLoadingMore
                ? const LoadingIndicator(padding: DesignTokens.spacing24)
                : const SizedBox.shrink();
          }
          return ItemCard(
            item: items[index],
            onTap: () => _handleItemTap(items[index]),
          );
        },
        childCount: items.length + (isLoadingMore ? 1 : 0),
        semanticIndexCallback: (Widget widget, int localIndex) => localIndex,
      ),
    );
  }
}
```

## 7. Positioned Elements (If Used)

```dart
// ✅ ALWAYS wrap positioned UI elements with SafeArea
Positioned(
  top: MediaQuery.of(context).padding.top + 16,
  left: 16,
  child: SafeArea(  // Additional SafeArea for positioned elements
    child: Container(
      // Your positioned content
    ),
  ),
),
```

## Production Mobile Checklist

**Code review requirements - ALL must pass before deployment:**

### ✅ Core Mobile Architecture
- [ ] `SafeArea` wrapper around all Scaffold body content
- [ ] `resizeToAvoidBottomInset: true` for text input pages
- [ ] Bottom spacing includes `MediaQuery.of(context).padding.bottom`
- [ ] `FloatingActionButton` positioning accounts for system UI (if used)
- [ ] CustomScrollView with proper physics for scrollable content
- [ ] `SliverFillRemaining` implementation for all empty states

### ✅ Production Standards
- [ ] Proper state management (Provider/Riverpod, no setState in production)
- [ ] Internationalization with `context.l10n` for all user-facing text
- [ ] Design tokens used throughout (no hardcoded values)
- [ ] Error handling with user-friendly messages and retry mechanisms
- [ ] Loading states with proper accessibility labels
- [ ] Performance optimization (AutomaticKeepAliveClientMixin where appropriate)

### ✅ Accessibility & UX
- [ ] Semantic labels for all interactive elements
- [ ] Touch targets minimum 48dp (verified via accessibility inspector)
- [ ] Screen reader navigation tested with TalkBack/VoiceOver
- [ ] High contrast mode compatibility
- [ ] Keyboard navigation support where applicable
- [ ] Pull-to-refresh implementation for data lists

## Production Anti-Patterns (Code Review Blockers)

### ❌ Beginner State Management
```dart
class _PageState extends State<Page> {
  bool _isLoading = false;  // ❌ setState in production code
  List<Item> _items = [];
  
  void _loadData() async {
    setState(() => _isLoading = true);  // ❌ No error handling
    _items = await api.fetchItems();   // ❌ Unhandled exceptions
    setState(() => _isLoading = false);
  }
}
```

### ❌ Missing Accessibility & Internationalization
```dart
Text('Loading...'),  // ❌ Hardcoded string
CircularProgressIndicator(), // ❌ No semantic label
IconButton(
  onPressed: () {},
  icon: Icon(Icons.add), // ❌ No semantic label
),
FilledButton(
  onPressed: () {},
  child: Text('Submit'), // ❌ Hardcoded string, no loading state
),
```

### ❌ Poor Mobile Architecture
```dart
Scaffold(
  body: Column(  // ❌ No SafeArea, content cutoff
    children: [
      Container(
        padding: EdgeInsets.all(16), // ❌ Hardcoded padding
        child: Text('Title', style: TextStyle(fontSize: 24)), // ❌ Hardcoded style
      ),
      Expanded(
        child: ListView.builder(...), // ❌ Separate scroll context
      ),
    ],
  ),
)
```

### ❌ Missing Error Boundaries
```dart
FutureBuilder<List<Item>>(
  future: fetchItems(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView(children: snapshot.data!.map(...).toList());
    }
    return CircularProgressIndicator(); // ❌ No error handling
  },
)
```

## ✅ Production Standards Summary

Your Flutter code must demonstrate:
- **Enterprise-grade state management** with proper error boundaries
- **Complete accessibility support** with semantic labels and screen reader compatibility  
- **Full internationalization** using app localization
- **Theme consistency** through design tokens
- **Mobile-first architecture** with SafeArea and proper scroll physics
- **Performance optimization** with keep-alive mixins and efficient rebuilds

These requirements ensure your code meets production deployment standards and passes code review processes.