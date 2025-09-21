import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class DeepLinkingService {
  static final DeepLinkingService _instance = DeepLinkingService._internal();
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();

  final StreamController<DeepLinkData> _linkStreamController = StreamController<DeepLinkData>.broadcast();
  Stream<DeepLinkData> get linkStream => _linkStreamController.stream;

  bool _isInitialized = false;
  String _lastUrl = '';

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    _setupWebDeepLinking();
  }

  void _setupWebDeepLinking() {
    // Listen for browser back/forward events
    try {
      // Use a simple approach that works with current web package
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final currentUrl = web.window.location.href;
        if (_lastUrl != currentUrl) {
          _lastUrl = currentUrl;
          _handleRouteChange();
        }
      });
    } catch (e) {
      debugPrint('Failed to setup web deep linking: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialRoute();
    });
  }

  void _handleInitialRoute() {
    final currentUrl = web.window.location.href;
    final linkData = _parseUrl(currentUrl);
    if (linkData != null) {
      _linkStreamController.add(linkData);
    }
  }

  void _handleRouteChange() {
    final currentUrl = web.window.location.href;
    final linkData = _parseUrl(currentUrl);
    if (linkData != null) {
      _linkStreamController.add(linkData);
    }
  }

  DeepLinkData? _parseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      if (uri.pathSegments.isEmpty) {
        return DeepLinkData(
          route: '/sessions_list',
          type: DeepLinkType.sessionsList,
        );
      }

      switch (uri.pathSegments.length) {
        case 1:
          return _parseSingleSegment(uri);
        case 2:
          return _parseTwoSegments(uri);
        case 3:
          return _parseThreeSegments(uri);
        default:
          return null;
      }
    } catch (e) {
      debugPrint('Error parsing URL: $e');
      return null;
    }
  }

  DeepLinkData? _parseSingleSegment(Uri uri) {
    switch (uri.pathSegments[0]) {
      case 'sessions':
        return DeepLinkData(route: '/sessions_list', type: DeepLinkType.sessionsList);
      case 'create':
        return DeepLinkData(route: '/session_create', type: DeepLinkType.sessionCreate);
      default:
        return null;
    }
  }

  DeepLinkData? _parseTwoSegments(Uri uri) {
    if (uri.pathSegments[0] == 'session') {
      final sessionIdOrCode = uri.pathSegments[1];
      final sessionId = int.tryParse(sessionIdOrCode);
      
      if (sessionId != null) {
        return DeepLinkData(
          route: '/session/$sessionId',
          type: DeepLinkType.sessionTemplate,
          data: {'sessionId': sessionId},
        );
      } else {
        return DeepLinkData(
          route: '/session/$sessionIdOrCode',
          type: DeepLinkType.sessionTemplateByCode,
          data: {'sessionCode': sessionIdOrCode},
        );
      }
    }
    
    if (uri.pathSegments[0] == 'qr' && uri.pathSegments[1] == 'share') {
      final sessionId = int.tryParse(uri.queryParameters['sessionId'] ?? '');
      if (sessionId != null) {
        return DeepLinkData(
          route: '/qr_code',
          type: DeepLinkType.qrShare,
          data: {'sessionId': sessionId},
        );
      }
    }
    
    return null;
  }

  DeepLinkData? _parseThreeSegments(Uri uri) {
    if (uri.pathSegments[0] == 'session' && uri.pathSegments[1] == 'results') {
      final sessionId = int.tryParse(uri.pathSegments[2]);
      if (sessionId != null) {
        final templateId = int.tryParse(uri.queryParameters['templateId'] ?? '');
        return DeepLinkData(
          route: '/results',
          type: DeepLinkType.sessionResults,
          data: {
            'sessionId': sessionId,
            if (templateId != null) 'templateId': templateId,
          },
        );
      }
    }
    return null;
  }

  void pushUrl(String path, {Map<String, String>? queryParams}) {
    final uri = Uri(path: path, queryParameters: queryParams);
    final url = uri.toString();
    
    try {
      web.window.history.pushState(null, '', url);
    } catch (e) {
      debugPrint('Error pushing URL: $e');
    }
  }

  void replaceUrl(String path, {Map<String, String>? queryParams}) {
    final uri = Uri(path: path, queryParameters: queryParams);
    final url = uri.toString();
    
    try {
      web.window.history.replaceState(null, '', url);
    } catch (e) {
      debugPrint('Error replacing URL: $e');
    }
  }

  String generateShareableUrl(int sessionId, {String? baseUrl}) {
    final base = baseUrl ?? web.window.location.origin;
    return '$base/session/$sessionId';
  }

  String generateResultsUrl(int sessionId, {int? templateId, String? baseUrl}) {
    final base = baseUrl ?? web.window.location.origin;
    final url = '$base/session/results/$sessionId';
    
    if (templateId != null) {
      return '$url?templateId=$templateId';
    }
    return url;
  }

  String generateQrShareUrl(int sessionId, {String? baseUrl}) {
    final base = baseUrl ?? web.window.location.origin;
    return '$base/qr/share?sessionId=$sessionId';
  }

  void dispose() {
    _linkStreamController.close();
  }
}

class DeepLinkData {
  final String route;
  final DeepLinkType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  DeepLinkData({
    required this.route,
    required this.type,
    this.data = const {},
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'DeepLinkData(route: $route, type: $type, data: $data, timestamp: $timestamp)';
  }
}

enum DeepLinkType {
  sessionsList,
  sessionCreate,
  sessionTemplate,
  sessionTemplateByCode,
  sessionResults,
  qrShare,
}

class DeepLinkHandler {
  static void handleDeepLink(BuildContext context, DeepLinkData linkData) {
    switch (linkData.type) {
      case DeepLinkType.sessionTemplate:
        final sessionId = linkData.data['sessionId'] as int;
        Navigator.of(context).pushNamed('/session/$sessionId');
        break;
        
      case DeepLinkType.sessionTemplateByCode:
        final sessionCode = linkData.data['sessionCode'] as String;
        Navigator.of(context).pushNamed('/session/$sessionCode');
        break;
        
      case DeepLinkType.sessionResults:
        final sessionId = linkData.data['sessionId'] as int;
        final templateId = linkData.data['templateId'] as int?;
        Navigator.of(context).pushNamed(
          '/session/results/$sessionId',
          arguments: templateId != null ? {'templateId': templateId} : null,
        );
        break;
        
      case DeepLinkType.qrShare:
        final sessionId = linkData.data['sessionId'] as int;
        Navigator.of(context).pushNamed('/qr/share', arguments: {'sessionId': sessionId});
        break;
        
      default:
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        break;
    }
  }
}