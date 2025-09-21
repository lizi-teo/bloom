import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class TemplateService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Fetches image URL for a given template ID
  Future<String?> getTemplateImageUrl(int templateId) async {
    try {
      final response = await _supabase
          .from('templates')
          .select('image_url')
          .eq('template_id', templateId)
          .single();
      
      return response['image_url'] as String?;
    } catch (e) {
      debugPrint('Error fetching template image URL: $e');
      return null;
    }
  }
  
  /// Fetches image URL for a given session ID
  /// (Sessions are linked to templates through template_id)
  Future<String?> getSessionImageUrl(int sessionId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select('template_id')
          .eq('session_id', sessionId)
          .single();
      
      final templateId = response['template_id'] as int?;
      if (templateId != null) {
        return getTemplateImageUrl(templateId);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching session image URL: $e');
      return null;
    }
  }
  
  /// Fetches template details including image URL
  Future<Map<String, dynamic>?> getTemplateDetails(int templateId) async {
    try {
      final response = await _supabase
          .from('templates')
          .select('*')
          .eq('template_id', templateId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching template details: $e');
      return null;
    }
  }
  
  /// Fetches all templates
  Future<List<Map<String, dynamic>>> getAllTemplates() async {
    try {
      final response = await _supabase
          .from('templates')
          .select('*')
          .order('template_id', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching all templates: $e');
      return [];
    }
  }
}