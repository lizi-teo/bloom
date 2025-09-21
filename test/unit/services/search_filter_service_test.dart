import 'package:flutter_test/flutter_test.dart';
import 'package:bloom_app/core/services/search_filter_service.dart';

class TestItem {
  final int id;
  final String name;
  final String description;
  final int rating;
  final bool isActive;
  final DateTime createdAt;
  final List<String> tags;

  TestItem({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    required this.tags,
  });
}

void main() {
  group('SearchFilterService', () {
    late SearchFilterService<TestItem> service;
    late List<TestItem> testItems;

    setUp(() {
      service = SearchFilterService<TestItem>();
      testItems = [
        TestItem(
          id: 1,
          name: 'Flutter App',
          description: 'A mobile application built with Flutter',
          rating: 5,
          isActive: true,
          createdAt: DateTime(2024, 1, 1),
          tags: ['mobile', 'flutter', 'dart'],
        ),
        TestItem(
          id: 2,
          name: 'React Website',
          description: 'A web application built with React',
          rating: 4,
          isActive: true,
          createdAt: DateTime(2024, 2, 1),
          tags: ['web', 'react', 'javascript'],
        ),
        TestItem(
          id: 3,
          name: 'Vue Dashboard',
          description: 'An admin dashboard built with Vue.js',
          rating: 3,
          isActive: false,
          createdAt: DateTime(2024, 3, 1),
          tags: ['web', 'vue', 'javascript'],
        ),
      ];

      // Add text search filter
      service.addFilter(TextSearchFilter<TestItem>(
        id: 'name_search',
        displayName: 'Name Search',
        textExtractor: (item) => item.name,
      ));

      service.addFilter(TextSearchFilter<TestItem>(
        id: 'description_search',
        displayName: 'Description Search',
        textExtractor: (item) => item.description,
      ));
    });

    tearDown(() {
      service.dispose();
    });

    group('Text Search', () {
      test('should find items by name', () async {
        final results = await service.searchAndFilter(testItems, 'Flutter');
        
        expect(results.resultCount, equals(1));
        expect(results.items.first.name, equals('Flutter App'));
      });

      test('should find items by description', () async {
        final results = await service.searchAndFilter(testItems, 'mobile');
        
        expect(results.resultCount, equals(1));
        expect(results.items.first.description, contains('mobile'));
      });

      test('should be case insensitive', () async {
        final results = await service.searchAndFilter(testItems, 'FLUTTER');
        
        expect(results.resultCount, equals(1));
        expect(results.items.first.name, equals('Flutter App'));
      });

      test('should find items with partial matches', () async {
        final results = await service.searchAndFilter(testItems, 'app');
        
        expect(results.resultCount, greaterThan(0));
      });

      test('should return all items for empty query', () async {
        final results = await service.searchAndFilter(testItems, '');
        
        expect(results.resultCount, equals(testItems.length));
      });

      test('should return empty results for no matches', () async {
        final results = await service.searchAndFilter(testItems, 'nonexistent');
        
        expect(results.resultCount, equals(0));
        expect(results.items, isEmpty);
      });
    });

    group('Filters', () {
      setUp(() {
        service.addFilter(BooleanFilter<TestItem>(
          id: 'active_filter',
          displayName: 'Active Only',
          valueExtractor: (item) => item.isActive,
        ));

        service.addFilter(RangeFilter<TestItem, num>(
          id: 'rating_filter',
          displayName: 'Rating Range',
          valueExtractor: (item) => item.rating,
        ));

        service.addFilter(MultiSelectFilter<TestItem>(
          id: 'tags_filter',
          displayName: 'Tags Filter',
          valuesExtractor: (item) => item.tags,
        ));
      });

      test('should filter by boolean value', () async {
        final results = await service.searchAndFilter(
          testItems,
          '',
          filters: {'active_filter': true},
        );
        
        expect(results.resultCount, equals(2));
        expect(results.items.every((item) => item.isActive), isTrue);
      });

      test('should filter by range', () async {
        final results = await service.searchAndFilter(
          testItems,
          '',
          filters: {'rating_filter': {'min': 4, 'max': 5}},
        );
        
        expect(results.resultCount, equals(2));
        expect(results.items.every((item) => item.rating >= 4), isTrue);
      });

      test('should filter by multi-select', () async {
        final results = await service.searchAndFilter(
          testItems,
          '',
          filters: {'tags_filter': ['flutter']},
        );
        
        expect(results.resultCount, equals(1));
        expect(results.items.first.tags, contains('flutter'));
      });

      test('should combine multiple filters', () async {
        final results = await service.searchAndFilter(
          testItems,
          '',
          filters: {
            'active_filter': true,
            'rating_filter': {'min': 4, 'max': 5},
          },
        );
        
        expect(results.resultCount, equals(2));
        expect(results.items.every((item) => item.isActive && item.rating >= 4), isTrue);
      });
    });

    group('Sorting', () {
      test('should sort by rating ascending', () async {
        final sortConfig = SortConfig<TestItem>(
          field: 'rating',
          comparator: (a, b) => a.rating.compareTo(b.rating),
          descending: false,
        );

        final results = await service.searchAndFilter(
          testItems,
          '',
          sortConfig: sortConfig,
        );
        
        expect(results.items[0].rating, equals(3));
        expect(results.items[1].rating, equals(4));
        expect(results.items[2].rating, equals(5));
      });

      test('should sort by rating descending', () async {
        final sortConfig = SortConfig<TestItem>(
          field: 'rating',
          comparator: (a, b) => b.rating.compareTo(a.rating),
          descending: false,
        );

        final results = await service.searchAndFilter(
          testItems,
          '',
          sortConfig: sortConfig,
        );
        
        expect(results.items[0].rating, equals(5));
        expect(results.items[1].rating, equals(4));
        expect(results.items[2].rating, equals(3));
      });
    });

    group('Search Results', () {
      test('should provide correct statistics', () async {
        final results = await service.searchAndFilter(testItems, 'app');
        
        expect(results.totalItems, equals(testItems.length));
        expect(results.query, equals('app'));
        expect(results.hasQuery, isTrue);
        expect(results.hasResults, isTrue);
        expect(results.matchPercentage, greaterThan(0));
        expect(results.stats, isA<SearchStats>());
      });

      test('should indicate no results correctly', () async {
        final results = await service.searchAndFilter(testItems, 'nonexistent');
        
        expect(results.hasResults, isFalse);
        expect(results.resultCount, equals(0));
        expect(results.matchPercentage, equals(0));
      });

      test('should indicate no query correctly', () async {
        final results = await service.searchAndFilter(testItems, '');
        
        expect(results.hasQuery, isFalse);
        expect(results.query, isEmpty);
      });

      test('should indicate filters correctly', () async {
        final results = await service.searchAndFilter(
          testItems,
          '',
          filters: {'active_filter': true},
        );
        
        expect(results.hasFilters, isTrue);
        expect(results.activeFilters, containsPair('active_filter', true));
      });
    });

    group('Filter Management', () {
      test('should add and remove filters', () {
        // Since _filters is private, we test the functionality indirectly
        service.addFilter(TextSearchFilter<TestItem>(
          id: 'test_filter',
          displayName: 'Test Filter',
          textExtractor: (item) => item.name,
        ));
        
        // Test that the filter works
        final resultsWithFilter = service.searchAndFilter(
          testItems, 
          '',
          filters: {'test_filter': 'Flutter'},
        );
        
        expect(resultsWithFilter, completes);
        
        service.removeFilter('test_filter');
        
        // After removal, the filter should not exist
        expect(
          () => service.searchAndFilter(testItems, '', filters: {'test_filter': 'Flutter'}),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should clear all filters', () {
        service.clearFilters();
        
        // After clearing, searching should still work but with no filters
        final results = service.searchAndFilter(testItems, 'Flutter');
        expect(results, completes);
      });
    });
  });

  group('Filter Classes', () {
    group('TextSearchFilter', () {
      test('should extract text correctly', () {
        final filter = TextSearchFilter<TestItem>(
          id: 'name_filter',
          displayName: 'Name Filter',
          textExtractor: (item) => item.name,
        );

        final item = TestItem(
          id: 1,
          name: 'Test Item',
          description: 'Test Description',
          rating: 5,
          isActive: true,
          createdAt: DateTime.now(),
          tags: [],
        );

        expect(filter.predicate(item, 'Test'), isTrue);
        expect(filter.predicate(item, 'test'), isTrue);
        expect(filter.predicate(item, 'Item'), isTrue);
        expect(filter.predicate(item, 'NonExistent'), isFalse);
      });
    });

    group('RangeFilter', () {
      test('should filter by range correctly', () {
        final filter = RangeFilter<TestItem, num>(
          id: 'rating_filter',
          displayName: 'Rating Filter',
          valueExtractor: (item) => item.rating,
        );

        final item = TestItem(
          id: 1,
          name: 'Test',
          description: 'Test',
          rating: 4,
          isActive: true,
          createdAt: DateTime.now(),
          tags: [],
        );

        expect(filter.predicate(item, {'min': 3, 'max': 5}), isTrue);
        expect(filter.predicate(item, {'min': 5, 'max': 6}), isFalse);
        expect(filter.predicate(item, {'min': 1, 'max': 3}), isFalse);
      });
    });

    group('BooleanFilter', () {
      test('should filter by boolean correctly', () {
        final filter = BooleanFilter<TestItem>(
          id: 'active_filter',
          displayName: 'Active Filter',
          valueExtractor: (item) => item.isActive,
        );

        final activeItem = TestItem(
          id: 1,
          name: 'Test',
          description: 'Test',
          rating: 4,
          isActive: true,
          createdAt: DateTime.now(),
          tags: [],
        );

        final inactiveItem = TestItem(
          id: 2,
          name: 'Test',
          description: 'Test',
          rating: 4,
          isActive: false,
          createdAt: DateTime.now(),
          tags: [],
        );

        expect(filter.predicate(activeItem, true), isTrue);
        expect(filter.predicate(activeItem, false), isFalse);
        expect(filter.predicate(inactiveItem, true), isFalse);
        expect(filter.predicate(inactiveItem, false), isTrue);
      });
    });

    group('MultiSelectFilter', () {
      test('should filter by multi-select correctly', () {
        final filter = MultiSelectFilter<TestItem>(
          id: 'tags_filter',
          displayName: 'Tags Filter',
          valuesExtractor: (item) => item.tags,
        );

        final item = TestItem(
          id: 1,
          name: 'Test',
          description: 'Test',
          rating: 4,
          isActive: true,
          createdAt: DateTime.now(),
          tags: ['flutter', 'mobile', 'dart'],
        );

        expect(filter.predicate(item, ['flutter']), isTrue);
        expect(filter.predicate(item, ['web']), isFalse);
        expect(filter.predicate(item, ['flutter', 'web']), isTrue);
        expect(filter.predicate(item, []), isTrue);
      });
    });
  });
}