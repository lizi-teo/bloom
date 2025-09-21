import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bloom_app/core/providers/auth_provider.dart';
import 'package:bloom_app/core/providers/navigation_provider.dart';
import 'package:bloom_app/core/themes/theme_provider.dart';

class TestHelpers {
  static Widget createTestableWidget({
    required Widget child,
    List<Provider> providers = const [],
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<NavigationProvider>(create: (_) => NavigationProvider()),
        ...providers,
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  static Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  static Finder findByTestKey(String key) {
    return find.byKey(Key(key));
  }

  static Finder findByIcon(IconData icon) {
    return find.byIcon(icon);
  }

  static Finder findByType<T>() {
    return find.byType(T);
  }

  static Finder findTextContaining(String text) {
    return find.textContaining(text);
  }

  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  static void expectToFindText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  static void expectToFindNWidgets(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  static void expectToFindWidget(Finder finder) {
    expect(finder, findsOneWidget);
  }

  static void expectNotToFindWidget(Finder finder) {
    expect(finder, findsNothing);
  }

  static Map<String, dynamic> createMockSessionData({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return {
      'id': id ?? 1,
      'title': title ?? 'Test Session',
      'description': description ?? 'Test Description',
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'is_active': isActive ?? true,
      'session_code': 'TEST123',
      'template_id': 1,
    };
  }

  static Map<String, dynamic> createMockTemplateData({
    int? id,
    String? title,
    String? description,
  }) {
    return {
      'id': id ?? 1,
      'title': title ?? 'Test Template',
      'description': description ?? 'Test Template Description',
      'questions': [
        {
          'id': 1,
          'text': 'Test Question 1',
          'type': 'text',
          'required': true,
        },
        {
          'id': 2,
          'text': 'Test Question 2',
          'type': 'rating',
          'required': false,
        },
      ],
    };
  }

  static Map<String, dynamic> createMockUserData({
    String? id,
    String? email,
    String? displayName,
  }) {
    return {
      'id': id ?? 'test-user-id',
      'email': email ?? 'test@example.com',
      'display_name': displayName ?? 'Test User',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    if (!condition()) {
      throw TimeoutException(
        'Condition not met within ${timeout.inMilliseconds}ms',
        timeout,
      );
    }
  }
}

class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];
  final List<Route<dynamic>> replacedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      replacedRoutes.add(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
    replacedRoutes.clear();
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message';
}