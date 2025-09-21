class Session {
  final int? sessionId;
  final int? templateId;
  final String? sessionName;
  final DateTime? createdAt;
  final String? sessionCode;
  final String? participantAccessUrl;

  const Session({
    this.sessionId,
    this.templateId,
    this.sessionName,
    this.createdAt,
    this.sessionCode,
    this.participantAccessUrl,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] as int?,
      templateId: json['template_id'] as int?,
      sessionName: json['session_name'] as String?, // Note: keeping typo from DB
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      sessionCode: json['session_code'] as String?,
      participantAccessUrl: json['participant_access_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'session_id': sessionId,
      if (templateId != null) 'template_id': templateId,
      if (sessionName != null) 'session_name': sessionName, // Note: keeping typo from DB
      if (createdAt != null) 'created_at': createdAt!.toIso8601String().split('T')[0],
      if (sessionCode != null) 'session_code': sessionCode,
      if (participantAccessUrl != null) 'participant_access_url': participantAccessUrl,
    };
  }

  Session copyWith({
    int? sessionId,
    int? templateId,
    String? sessionName,
    DateTime? createdAt,
    String? sessionCode,
    String? participantAccessUrl,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      templateId: templateId ?? this.templateId,
      sessionName: sessionName ?? this.sessionName,
      createdAt: createdAt ?? this.createdAt,
      sessionCode: sessionCode ?? this.sessionCode,
      participantAccessUrl: participantAccessUrl ?? this.participantAccessUrl,
    );
  }
}
