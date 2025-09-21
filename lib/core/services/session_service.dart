import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:web/web.dart' as web;
import '../../features/sessions/models/session.dart' as app_models;
import '../../features/sessions/models/template.dart';
import '../../features/sessions/models/session_with_template.dart';
import 'auth_service.dart';

class SessionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<List<Template>> getTemplates() async {
    try {
      final response = await _supabase.from('templates').select('template_id, template_name');

      return (response as List).map((json) => Template.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load templates: $e');
    }
  }

  Future<app_models.Session> createSession({
    required String sessionName,
    required int templateId,
  }) async {
    // Check if user is authenticated
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to create sessions');
    }

    const maxAttempts = 10;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        // Generate session code and participant access URL
        final sessionCode = _generateSessionCode();
        
        // Dynamically get the current base URL for development
        String baseUrl = const String.fromEnvironment('APP_BASE_URL', defaultValue: 'https://bloom-e0901.web.app');
        
        // In development, use the current window location if available
        if (baseUrl.contains('localhost')) {
          try {
            // For Flutter web, use the current page URL
            final currentUrl = web.window.location.href;
            if (currentUrl.contains('localhost')) {
              final uri = Uri.parse(currentUrl);
              baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
              debugPrint('Detected current base URL: $baseUrl');
            }
          } catch (e) {
            // Fallback to config value if window access fails
            debugPrint('Could not detect current URL, using config value: $e');
          }
        }
        
        final participantAccessUrl = '$baseUrl/#/session/$sessionCode';

        final response = await _supabase
            .from('sessions')
            .insert({
              'session_name': sessionName, // Note: keeping DB typo
              'template_id': templateId,
              'session_code': sessionCode,
              'participant_access_url': participantAccessUrl,
              'created_at': DateTime.now().toIso8601String(),
              'facilitator_id': currentUser.id,
            })
            .select('session_id, template_id, session_name, session_code, participant_access_url, created_at')
            .single();

        return app_models.Session.fromJson(response);
      } catch (e) {
        // If unique constraint violation on session_code, try again with a new code
        if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
          attempts++;
          if (attempts >= maxAttempts) {
            throw Exception('Could not generate unique session code after $maxAttempts attempts');
          }
        } else {
          // Some other error - rethrow it
          throw Exception('Failed to create session: $e');
        }
      }
    }

    throw Exception('Failed to create session after $maxAttempts attempts');
  }

  Future<List<app_models.Session>> getSessions() async {
    try {
      // Check if user is authenticated
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to view sessions');
      }

      final response = await _supabase
          .from('sessions')
          .select('session_id, template_id, session_name, created_at')
          .eq('facilitator_id', currentUser.id)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .order('session_id', ascending: false);

      return (response as List).map((json) => app_models.Session.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load sessions: $e');
    }
  }

  Future<app_models.Session?> getSession(int sessionId) async {
    try {
      // This method is used by participants accessing sessions via session codes,
      // so we don't filter by facilitator_id here to maintain participant access
      final response = await _supabase.from('sessions').select('session_id, template_id, session_name, created_at').eq('session_id', sessionId).maybeSingle();

      return response != null ? app_models.Session.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to load session: $e');
    }
  }

  Future<List<SessionWithTemplate>> getSessionsWithTemplates() async {
    try {
      debugPrint('🔍 Loading sessions with templates...');
      
      // Check if user is authenticated
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to view sessions');
      }
      
      // Get sessions first (filtered by current user and not deleted)
      final sessions = await _supabase.from('sessions').select(
        'session_id, template_id, session_name, created_at'
      ).eq('facilitator_id', currentUser.id)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .order('session_id', ascending: false);

      debugPrint('✅ Loaded ${sessions.length} sessions');

      // Get all templates
      final templates = await _supabase.from('templates').select(
        'template_id, template_name, image_url, supporting_text'
      );

      debugPrint('✅ Loaded ${templates.length} templates');

      // Create a map of templates for quick lookup
      final templatesMap = <int, Map<String, dynamic>>{};
      for (final template in templates) {
        templatesMap[template['template_id'] as int] = template;
      }

      // Get count of results for each session and build final objects
      final List<SessionWithTemplate> sessionsWithCounts = [];
      for (final sessionJson in sessions) {
        final sessionData = Map<String, dynamic>.from(sessionJson);
        final sessionId = sessionData['session_id'] as int;
        final templateId = sessionData['template_id'] as int?;

        // Add template data if it exists
        if (templateId != null && templatesMap.containsKey(templateId)) {
          sessionData['templates'] = templatesMap[templateId];
        }

        // Count results for this session
        final resultsCountResponse = await _supabase.from('results').select('results_id').eq('session_id', sessionId);

        final resultsCount = (resultsCountResponse as List).length;

        // Add the count to the session data
        sessionData['results_count'] = resultsCount;

        try {
          sessionsWithCounts.add(SessionWithTemplate.fromJson(sessionData));
        } catch (parseError) {
          debugPrint('❌ Error parsing session data: $parseError');
          debugPrint('📄 Session data: $sessionData');
          rethrow;
        }
      }

      debugPrint('🎉 Successfully loaded ${sessionsWithCounts.length} sessions with templates');
      return sessionsWithCounts;
    } catch (e) {
      debugPrint('❌ Failed to load sessions with templates: $e');
      throw Exception('Failed to load sessions with templates: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getResultsForSession(int sessionId) async {
    try {
      final response = await _supabase.from('results').select('results_id, session_id, created_at').eq('session_id', sessionId).order('created_at', ascending: false);

      return (response as List).map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to load results for session: $e');
    }
  }

  Future<void> deleteSession(int sessionId) async {
    try {
      // Check if user is authenticated
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to delete sessions');
      }

      // First verify the session belongs to the current user and is not already deleted
      final sessionResponse = await _supabase
          .from('sessions')
          .select('session_id, facilitator_id')
          .eq('session_id', sessionId)
          .eq('facilitator_id', currentUser.id)
          .maybeSingle();

      if (sessionResponse == null) {
        throw Exception('Session not found or you do not have permission to delete it');
      }

      // Soft delete the session by setting deleted_at timestamp
      await _supabase
          .from('sessions')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('session_id', sessionId)
          .eq('facilitator_id', currentUser.id);

      debugPrint('✅ Successfully soft deleted session $sessionId');
    } catch (e) {
      debugPrint('❌ Failed to delete session: $e');
      throw Exception('Failed to delete session: $e');
    }
  }
}
