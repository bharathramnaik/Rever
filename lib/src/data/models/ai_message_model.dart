class AiMessageModel {
  final String id;
  final String sessionId;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<Map<String, dynamic>> groundingSources;
  final DateTime createdAt;

  const AiMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.groundingSources = const [],
    required this.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      groundingSources: json['grounding_sources'] != null
          ? (json['grounding_sources'] as List)
              .cast<Map<String, dynamic>>()
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'role': role,
        'content': content,
        'grounding_sources': groundingSources,
      };

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
