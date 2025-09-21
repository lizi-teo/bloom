import 'package:flutter/material.dart';
import '../../features/sessions/widgets/session_create_content.dart';
import '../../features/sessions/widgets/sessions_list_content.dart';
import '../../features/qr_codes/widgets/qr_code_share_content.dart';
import '../../features/results/widgets/results_content.dart';
import '../services/deep_linking_service.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentRoute = '/sessions_list';
  Map<String, dynamic> _routeData = {};
  final List<NavigationHistoryEntry> _history = [];
  final DeepLinkingService _deepLinkingService = DeepLinkingService();
  
  NavigationProvider() {
    _deepLinkingService.initialize();
  }

  String get currentRoute => _currentRoute;
  Map<String, dynamic> get routeData => _routeData;
  bool get canGoBack => _history.isNotEmpty;
  List<NavigationHistoryEntry> get history => List.unmodifiable(_history);
  DeepLinkingService get deepLinkingService => _deepLinkingService;

  void navigateTo(String route, {Map<String, dynamic>? data, bool updateUrl = true}) {
    if (_currentRoute != route) {
      _history.add(NavigationHistoryEntry(
        route: _currentRoute,
        data: Map<String, dynamic>.from(_routeData),
        timestamp: DateTime.now(),
      ));
      _currentRoute = route;
      _routeData = data ?? {};
      
      if (updateUrl) {
        _updateUrl(route, data);
      }
      
      notifyListeners();
    }
  }

  void goBack({bool updateUrl = true}) {
    if (_history.isNotEmpty) {
      final previousEntry = _history.removeLast();
      _currentRoute = previousEntry.route;
      _routeData = previousEntry.data;
      
      if (updateUrl) {
        _updateUrl(_currentRoute, _routeData);
      }
      
      notifyListeners();
    }
  }

  void replaceCurrent(String route, {Map<String, dynamic>? data, bool updateUrl = true}) {
    _currentRoute = route;
    _routeData = data ?? {};
    
    if (updateUrl) {
      _deepLinkingService.replaceUrl(_getUrlPath(route), queryParams: _getQueryParams(data));
    }
    
    notifyListeners();
  }

  void navigateToQrCode(int sessionId) {
    navigateTo('/qr_code', data: {'sessionId': sessionId});
  }
  
  void _updateUrl(String route, Map<String, dynamic>? data) {
    final path = _getUrlPath(route);
    final queryParams = _getQueryParams(data);
    _deepLinkingService.pushUrl(path, queryParams: queryParams);
  }
  
  String _getUrlPath(String route) {
    switch (route) {
      case '/session_create':
        return '/create';
      case '/sessions_list':
        return '/sessions';
      case '/qr_code':
        return '/qr/share';
      case '/results':
        return '/session/results/${_routeData['sessionId']}';
      default:
        return route;
    }
  }
  
  Map<String, String>? _getQueryParams(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return null;
    
    final queryParams = <String, String>{};
    data.forEach((key, value) {
      if (value != null) {
        queryParams[key] = value.toString();
      }
    });
    
    return queryParams.isNotEmpty ? queryParams : null;
  }
  
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
  
  String generateShareableUrl(int sessionId) {
    return _deepLinkingService.generateShareableUrl(sessionId);
  }
  
  String generateResultsUrl(int sessionId, {int? templateId}) {
    return _deepLinkingService.generateResultsUrl(sessionId, templateId: templateId);
  }

  void navigateBackFromQrCode() {
    goBack();
  }

  void navigateToResults(int sessionId, {int? templateId}) {
    navigateTo('/results', data: {
      'sessionId': sessionId,
      if (templateId != null) 'templateId': templateId,
    });
  }

  Widget buildContent(BuildContext context) {
    switch (_currentRoute) {
      case '/session_create':
        return const SessionCreateContent();
      case '/sessions_list':
      case '/sessions':
        return const SessionsListContent();
      case '/qr_code':
        final sessionId = _routeData['sessionId'] as int?;
        if (sessionId == null) {
          return _buildErrorContent('Session ID required for QR code');
        }
        return QrCodeShareContent(sessionId: sessionId);
      case '/results':
        final sessionId = _routeData['sessionId'] as int?;
        final templateId = _routeData['templateId'] as int?;
        if (sessionId == null) {
          return _buildErrorContent('Session ID required for results');
        }
        return ResultsContent(sessionId: sessionId, templateId: templateId);
      default:
        // Default to sessions list for any unknown routes
        return const SessionsListContent();
    }
  }

  Widget _buildErrorContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class NavigationHistoryEntry {
  final String route;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  NavigationHistoryEntry({
    required this.route,
    required this.data,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'NavigationHistoryEntry(route: $route, data: $data, timestamp: $timestamp)';
  }
}