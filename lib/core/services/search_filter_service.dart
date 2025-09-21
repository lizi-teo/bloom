import 'dart:async';
import 'package:flutter/material.dart';

class SearchFilterService<T> {
  final List<SearchFilter<T>> _filters = [];
  final StreamController<SearchFilterResults<T>> _resultsController = 
      StreamController<SearchFilterResults<T>>.broadcast();
  
  Stream<SearchFilterResults<T>> get resultsStream => _resultsController.stream;
  
  Map<String, dynamic> _activeFilters = {};
  SortConfig<T>? _sortConfig;
  
  void addFilter(SearchFilter<T> filter) {
    _filters.add(filter);
  }
  
  void removeFilter(String filterId) {
    _filters.removeWhere((filter) => filter.id == filterId);
  }
  
  void clearFilters() {
    _filters.clear();
    _activeFilters.clear();
  }
  
  Future<SearchFilterResults<T>> searchAndFilter(
    List<T> items,
    String query, {
    Map<String, dynamic>? filters,
    SortConfig<T>? sortConfig,
  }) async {
    _activeFilters = filters ?? {};
    _sortConfig = sortConfig;
    
    var results = List<T>.from(items);
    final searchStats = SearchStats();
    
    // Apply text search
    if (query.isNotEmpty) {
      final searchResults = await _performTextSearch(results, query);
      results = searchResults.items;
      searchStats.searchTime = searchResults.searchTime;
      searchStats.matchedItems = results.length;
    }
    
    // Apply filters
    if (_activeFilters.isNotEmpty) {
      final filterResults = await _applyFilters(results);
      results = filterResults.items;
      searchStats.filterTime = filterResults.searchTime;
      searchStats.filteredItems = results.length;
    }
    
    // Apply sorting
    if (_sortConfig != null) {
      final sortResults = await _applySorting(results);
      results = sortResults.items;
      searchStats.sortTime = sortResults.searchTime;
    }
    
    final finalResults = SearchFilterResults<T>(
      items: results,
      query: query,
      activeFilters: Map<String, dynamic>.from(_activeFilters),
      totalItems: items.length,
      resultCount: results.length,
      stats: searchStats,
    );
    
    _resultsController.add(finalResults);
    return finalResults;
  }
  
  Future<_SearchResult<T>> _performTextSearch(List<T> items, String query) async {
    final stopwatch = Stopwatch()..start();
    
    final results = <T>[];
    final queryWords = query.toLowerCase().split(' ').where((w) => w.isNotEmpty);
    
    for (final item in items) {
      bool matches = false;
      
      for (final filter in _filters.where((f) => f.type == FilterType.text)) {
        final textFilter = filter as TextSearchFilter<T>;
        final searchText = textFilter.textExtractor(item).toLowerCase();
        
        // Check if all query words are present
        final hasAllWords = queryWords.every((word) => 
          searchText.contains(word) ||
          _fuzzyMatch(searchText, word, textFilter.fuzzyThreshold)
        );
        
        if (hasAllWords) {
          matches = true;
          break;
        }
      }
      
      if (matches) {
        results.add(item);
      }
    }
    
    stopwatch.stop();
    return _SearchResult(results, stopwatch.elapsedMicroseconds);
  }
  
  bool _fuzzyMatch(String text, String pattern, double threshold) {
    if (pattern.length < 3) return false; // Skip fuzzy matching for very short words
    
    final distance = _levenshteinDistance(text, pattern);
    final similarity = 1 - (distance / pattern.length);
    return similarity >= threshold;
  }
  
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));
    
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,     // deletion
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[len1][len2];
  }
  
  Future<_SearchResult<T>> _applyFilters(List<T> items) async {
    final stopwatch = Stopwatch()..start();
    
    var results = items;
    
    for (final filterEntry in _activeFilters.entries) {
      final filter = _filters.firstWhere(
        (f) => f.id == filterEntry.key,
        orElse: () => throw ArgumentError('Filter not found: ${filterEntry.key}'),
      );
      
      results = results.where((item) => filter.predicate(item, filterEntry.value)).toList();
    }
    
    stopwatch.stop();
    return _SearchResult(results, stopwatch.elapsedMicroseconds);
  }
  
  Future<_SearchResult<T>> _applySorting(List<T> items) async {
    final stopwatch = Stopwatch()..start();
    
    final results = List<T>.from(items);
    results.sort(_sortConfig!.comparator);
    
    if (_sortConfig!.descending) {
      final reversedResults = results.reversed.toList();
      results.clear();
      results.addAll(reversedResults);
    }
    
    stopwatch.stop();
    return _SearchResult(results, stopwatch.elapsedMicroseconds);
  }
  
  void dispose() {
    _resultsController.close();
  }
}

class _SearchResult<T> {
  final List<T> items;
  final int searchTime;
  
  _SearchResult(this.items, this.searchTime);
}

abstract class SearchFilter<T> {
  String get id;
  String get displayName;
  FilterType get type;
  bool predicate(T item, dynamic value);
}

class TextSearchFilter<T> extends SearchFilter<T> {
  @override
  final String id;
  @override
  final String displayName;
  final String Function(T) textExtractor;
  final double fuzzyThreshold;
  
  TextSearchFilter({
    required this.id,
    required this.displayName,
    required this.textExtractor,
    this.fuzzyThreshold = 0.7,
  });
  
  @override
  FilterType get type => FilterType.text;
  
  @override
  bool predicate(T item, dynamic value) {
    final text = textExtractor(item).toLowerCase();
    final query = value.toString().toLowerCase();
    return text.contains(query);
  }
}

class RangeFilter<T, V extends Comparable<V>> extends SearchFilter<T> {
  @override
  final String id;
  @override
  final String displayName;
  final V Function(T) valueExtractor;
  
  RangeFilter({
    required this.id,
    required this.displayName,
    required this.valueExtractor,
  });
  
  @override
  FilterType get type => FilterType.range;
  
  @override
  bool predicate(T item, dynamic value) {
    if (value is! Map<String, V>) return true;
    
    final itemValue = valueExtractor(item);
    final min = value['min'];
    final max = value['max'];
    
    if (min != null && itemValue.compareTo(min) < 0) return false;
    if (max != null && itemValue.compareTo(max) > 0) return false;
    
    return true;
  }
}

class MultiSelectFilter<T> extends SearchFilter<T> {
  @override
  final String id;
  @override
  final String displayName;
  final List<dynamic> Function(T) valuesExtractor;
  
  MultiSelectFilter({
    required this.id,
    required this.displayName,
    required this.valuesExtractor,
  });
  
  @override
  FilterType get type => FilterType.multiSelect;
  
  @override
  bool predicate(T item, dynamic value) {
    if (value is! List) return true;
    if (value.isEmpty) return true;
    
    final itemValues = valuesExtractor(item);
    return value.any((filterValue) => itemValues.contains(filterValue));
  }
}

class BooleanFilter<T> extends SearchFilter<T> {
  @override
  final String id;
  @override
  final String displayName;
  final bool Function(T) valueExtractor;
  
  BooleanFilter({
    required this.id,
    required this.displayName,
    required this.valueExtractor,
  });
  
  @override
  FilterType get type => FilterType.boolean;
  
  @override
  bool predicate(T item, dynamic value) {
    if (value is! bool) return true;
    return valueExtractor(item) == value;
  }
}

class DateRangeFilter<T> extends SearchFilter<T> {
  @override
  final String id;
  @override
  final String displayName;
  final DateTime Function(T) dateExtractor;
  
  DateRangeFilter({
    required this.id,
    required this.displayName,
    required this.dateExtractor,
  });
  
  @override
  FilterType get type => FilterType.dateRange;
  
  @override
  bool predicate(T item, dynamic value) {
    if (value is! DateTimeRange) return true;
    
    final itemDate = dateExtractor(item);
    return itemDate.isAfter(value.start.subtract(const Duration(days: 1))) &&
           itemDate.isBefore(value.end.add(const Duration(days: 1)));
  }
}

class SortConfig<T> {
  final String field;
  final int Function(T, T) comparator;
  final bool descending;
  
  SortConfig({
    required this.field,
    required this.comparator,
    this.descending = false,
  });
}

class SearchFilterResults<T> {
  final List<T> items;
  final String query;
  final Map<String, dynamic> activeFilters;
  final int totalItems;
  final int resultCount;
  final SearchStats stats;
  
  SearchFilterResults({
    required this.items,
    required this.query,
    required this.activeFilters,
    required this.totalItems,
    required this.resultCount,
    required this.stats,
  });
  
  bool get hasResults => items.isNotEmpty;
  bool get hasQuery => query.isNotEmpty;
  bool get hasFilters => activeFilters.isNotEmpty;
  double get matchPercentage => totalItems > 0 ? resultCount / totalItems : 0;
}

class SearchStats {
  int searchTime = 0;
  int filterTime = 0;
  int sortTime = 0;
  int matchedItems = 0;
  int filteredItems = 0;
  
  int get totalTime => searchTime + filterTime + sortTime;
}

enum FilterType {
  text,
  range,
  multiSelect,
  boolean,
  dateRange,
}

class SearchBarWidget extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;
  final TextEditingController? controller;
  final Widget? leading;
  final Widget? trailing;

  const SearchBarWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.showFilterButton = true,
    this.controller,
    this.leading,
    this.trailing,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search...',
          border: InputBorder.none,
          prefixIcon: widget.leading ?? const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                ),
              if (widget.showFilterButton)
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: widget.onFilterPressed,
                ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}