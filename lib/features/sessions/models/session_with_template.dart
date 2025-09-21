import 'session.dart';
import 'template.dart';

class SessionWithTemplate {
  final Session session;
  final Template? template;
  final int resultsCount;

  const SessionWithTemplate({
    required this.session,
    this.template,
    this.resultsCount = 0,
  });

  factory SessionWithTemplate.fromJson(Map<String, dynamic> json) {
    int resultsCount = 0;
    
    // Check for the new results_count field first
    if (json['results_count'] != null) {
      resultsCount = json['results_count'] as int? ?? 0;
    } else if (json['results'] != null) {
      // Fallback to old parsing logic for backwards compatibility
      final results = json['results'];
      if (results is List) {
        resultsCount = results.length;
      } else if (results is Map && results['count'] != null) {
        resultsCount = results['count'] as int? ?? 0;
      }
    }
    
    return SessionWithTemplate(
      session: Session.fromJson(json),
      template: json['templates'] != null
          ? Template.fromJson(json['templates'] as Map<String, dynamic>)
          : null,
      resultsCount: resultsCount,
    );
  }

  String get sessionName => session.sessionName ?? 'Unnamed Session';
  String get templateName => template?.templateName ?? 'No Template';
  String? get imageUrl => template?.imageUrl;
}