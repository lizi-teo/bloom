import 'package:flutter_test/flutter_test.dart';
import 'package:bloom_app/core/services/deep_linking_service.dart';

void main() {
  group('DeepLinkingService', () {
    late DeepLinkingService service;

    setUp(() {
      service = DeepLinkingService();
    });

    test('should be a singleton', () {
      final service1 = DeepLinkingService();
      final service2 = DeepLinkingService();
      expect(service1, equals(service2));
    });

    test('should generate correct shareable URL', () {
      const sessionId = 123;
      const baseUrl = 'https://example.com';
      
      final url = service.generateShareableUrl(sessionId, baseUrl: baseUrl);
      
      expect(url, equals('https://example.com/session/123'));
    });

    test('should generate correct results URL', () {
      const sessionId = 123;
      const templateId = 456;
      const baseUrl = 'https://example.com';
      
      final url = service.generateResultsUrl(
        sessionId,
        templateId: templateId,
        baseUrl: baseUrl,
      );
      
      expect(url, equals('https://example.com/session/results/123?templateId=456'));
    });

    test('should generate results URL without template ID', () {
      const sessionId = 123;
      const baseUrl = 'https://example.com';
      
      final url = service.generateResultsUrl(sessionId, baseUrl: baseUrl);
      
      expect(url, equals('https://example.com/session/results/123'));
    });

    test('should generate QR share URL', () {
      const sessionId = 123;
      const baseUrl = 'https://example.com';
      
      final url = service.generateQrShareUrl(sessionId, baseUrl: baseUrl);
      
      expect(url, equals('https://example.com/qr/share?sessionId=123'));
    });
  });

  group('DeepLinkData', () {
    test('should create with correct timestamp', () {
      final data = DeepLinkData(
        route: '/test',
        type: DeepLinkType.sessionsList,
        data: {'key': 'value'},
      );

      expect(data.route, equals('/test'));
      expect(data.type, equals(DeepLinkType.sessionsList));
      expect(data.data, equals({'key': 'value'}));
      expect(data.timestamp, isA<DateTime>());
    });

    test('should create with empty data by default', () {
      final data = DeepLinkData(
        route: '/test',
        type: DeepLinkType.sessionsList,
      );

      expect(data.data, isEmpty);
    });

    test('should have proper toString implementation', () {
      final data = DeepLinkData(
        route: '/test',
        type: DeepLinkType.sessionsList,
        data: {'key': 'value'},
      );

      final string = data.toString();
      expect(string, contains('route: /test'));
      expect(string, contains('type: DeepLinkType.sessionsList'));
      expect(string, contains('data: {key: value}'));
    });
  });

  group('DeepLinkType enum', () {
    test('should have all expected values', () {
      expect(DeepLinkType.values, contains(DeepLinkType.sessionsList));
      expect(DeepLinkType.values, contains(DeepLinkType.sessionCreate));
      expect(DeepLinkType.values, contains(DeepLinkType.sessionTemplate));
      expect(DeepLinkType.values, contains(DeepLinkType.sessionTemplateByCode));
      expect(DeepLinkType.values, contains(DeepLinkType.sessionResults));
      expect(DeepLinkType.values, contains(DeepLinkType.qrShare));
    });
  });
}