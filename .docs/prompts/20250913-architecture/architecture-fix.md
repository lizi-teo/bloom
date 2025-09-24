Current Problem:

  DashboardScreen (with ResponsiveLayoutWrapper)
    ↓ User clicks "Create Session"
  Navigator.push() → SessionCreateScreen (with NEW ResponsiveLayoutWrapper)

  Proposed Solution:

  1. Shell Container (Persistent)

  ShellScreen {
    ResponsiveLayoutWrapper (stays persistent) {
      Sidebar (persistent)
      ContentArea (changes based on navigation state)
    }
  }

  2. Content Widgets (Extracted)

  Extract the actual content from existing screens:

  From dashboard_screen.dart:
  - Extract _buildDashboardContent() logic → DashboardContent widget
  - Remove ResponsiveLayoutWrapper dependency

  From session_create_screen.dart:
  - Extract the form/content logic → SessionCreateContent widget
  - Remove Scaffold and navigation chrome

  From sessions_list_screen.dart:
  - Extract the list logic → SessionsListContent widget
  - Remove Scaffold and navigation chrome

  3. Navigation State Management

  NavigationProvider {
    String currentRoute = '/dashboard';

    navigateTo(String route) {
      currentRoute = route;
      notifyListeners(); // Only content area rebuilds
    }
  }

  4. Shell Routes Content

  Widget _buildContent() {
    switch (navigationProvider.currentRoute) {
      case '/dashboard':
        return DashboardContent(); // Extracted from dashboard_screen.dart
      case '/session/create':
        return SessionCreateContent(); // Extracted from session_create_screen.dart
      case '/sessions':
        return SessionsListContent(); // Extracted from sessions_list_screen.dart
    }
  }

  Key Benefits:

  - Sidebar stays intact - no recreation of ResponsiveLayoutWrapper
  - Only content area updates - much better performance
  - Existing screen logic preserved - just extracted into content widgets
  - URL routing still works - for web compatibility