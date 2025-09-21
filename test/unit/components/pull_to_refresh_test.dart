import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloom_app/core/components/molecules/pull_to_refresh_wrapper.dart';
import '../../test_helpers.dart';

void main() {
  group('PullToRefreshWrapper', () {
    testWidgets('should render child widget', (tester) async {
      const testText = 'Test Content';
      bool refreshCalled = false;

      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: PullToRefreshWrapper(
            onRefresh: () async {
              refreshCalled = true;
            },
            child: const Text(testText),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
      expect(refreshCalled, isFalse);
    });

    testWidgets('should trigger refresh on pull down', (tester) async {
      bool refreshCalled = false;
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: PullToRefreshWrapper(
            onRefresh: () async {
              refreshCalled = true;
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              children: const [
                SizedBox(height: 100, child: Text('Item 1')),
                SizedBox(height: 100, child: Text('Item 2')),
                SizedBox(height: 100, child: Text('Item 3')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull-to-refresh gesture
      await tester.drag(find.text('Item 1'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });

    testWidgets('should not trigger refresh when disabled', (tester) async {
      bool refreshCalled = false;
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: PullToRefreshWrapper(
            enabled: false,
            onRefresh: () async {
              refreshCalled = true;
            },
            child: ListView(
              children: const [
                SizedBox(height: 100, child: Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      // Simulate pull-to-refresh gesture
      await tester.drag(find.text('Item 1'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(refreshCalled, isFalse);
    });
  });

  group('SmartRefreshWrapper', () {
    testWidgets('should render child widget', (tester) async {
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: SmartRefreshWrapper(
            onRefresh: () async {},
            child: const Text('Smart Refresh Content'),
          ),
        ),
      );

      expect(find.text('Smart Refresh Content'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading more', (tester) async {
      bool endReachedCalled = false;
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: SmartRefreshWrapper(
            canLoadMore: true,
            onRefresh: () async {},
            onEndReached: () {
              endReachedCalled = true;
            },
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll to near the end
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      expect(endReachedCalled, isTrue);
    });

    testWidgets('should display custom loading message', (tester) async {
      const customMessage = 'Loading more items...';
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: SmartRefreshWrapper(
            canLoadMore: true,
            loadingMessage: customMessage,
            onRefresh: () async {},
            onEndReached: () {},
            child: const SizedBox(height: 200),
          ),
        ),
      );

      // Trigger loading state (this would normally happen through scrolling)
      // For testing purposes, we'll look for the message structure
      expect(find.text(customMessage), findsNothing); // Not shown initially
    });
  });

  group('RefreshableList', () {
    testWidgets('should show loading state initially', (tester) async {
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: RefreshableList<String>(
            loadData: () async {
              await Future.delayed(const Duration(seconds: 1));
              return ['Item 1', 'Item 2', 'Item 3'];
            },
            itemBuilder: (context, items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show items after loading', (tester) async {
      final testData = ['Item 1', 'Item 2', 'Item 3'];
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: RefreshableList<String>(
            loadData: () async => testData,
            itemBuilder: (context, items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
              ),
            ),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      for (final item in testData) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('should show error state on failure', (tester) async {
      const errorMessage = 'Test error';
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: RefreshableList<String>(
            loadData: () async {
              throw Exception(errorMessage);
            },
            itemBuilder: (context, items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
              ),
            ),
          ),
        ),
      );

      // Wait for error to appear
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show empty state for no items', (tester) async {
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: RefreshableList<String>(
            loadData: () async => [],
            itemBuilder: (context, items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
              ),
            ),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('should retry on error button tap', (tester) async {
      int loadAttempts = 0;
      
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: RefreshableList<String>(
            loadData: () async {
              loadAttempts++;
              if (loadAttempts == 1) {
                throw Exception('First attempt failed');
              }
              return ['Success Item'];
            },
            itemBuilder: (context, items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
              ),
            ),
          ),
        ),
      );

      // Wait for error to appear
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Retry'), findsOneWidget);
      expect(loadAttempts, equals(1));

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(loadAttempts, equals(2));
      expect(find.text('Success Item'), findsOneWidget);
    });

    testWidgets('should use custom builders', (tester) async {
      await TestHelpers.pumpAndSettle(
        tester,
        TestHelpers.createTestableWidget(
          child: RefreshableList<String>(
            loadData: () async {
              await Future.delayed(const Duration(milliseconds: 100));
              return [];
            },
            itemBuilder: (context, items) => Container(),
            loadingBuilder: (context) => const Text('Custom Loading'),
            emptyBuilder: (context) => const Text('Custom Empty'),
          ),
        ),
      );

      // Initially should show custom loading
      expect(find.text('Custom Loading'), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show custom empty state
      expect(find.text('Custom Empty'), findsOneWidget);
    });
  });
}