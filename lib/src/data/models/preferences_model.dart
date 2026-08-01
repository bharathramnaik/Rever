import 'explore_content_model.dart';

class PreferencesModel {
  final String profileId;
  final List<String> topics;
  final String goal;
  final String learningStyle;
  final int dailyGoalIdeas;

  const PreferencesModel({
    required this.profileId,
    this.topics = const [],
    this.goal = '',
    this.learningStyle = '',
    this.dailyGoalIdeas = 5,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) =>
      PreferencesModel(
        profileId: json['profile_id'] as String,
        topics: (json['topics'] as List?)?.cast<String>() ?? const [],
        goal: (json['goal'] as String?) ?? '',
        learningStyle: (json['learning_style'] as String?) ?? '',
        dailyGoalIdeas: (json['daily_goal_ideas'] as num?)?.toInt() ?? 5,
      );

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'topics': topics,
        'goal': goal,
        'learning_style': learningStyle,
        'daily_goal_ideas': dailyGoalIdeas,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
}

const kTopicOptions = [
  'Psychology',
  'Business & Money',
  'Science',
  'Technology',
  'Philosophy',
  'Health',
  'History',
  'Art & Design',
  'Productivity',
  'Personal Growth',
];

const kGoalOptions = [
  'Grow my career',
  'Build better habits',
  'Learn new skills',
  'Think more clearly',
  'Stay curious',
];

const kStyleOptions = [
  'Quick ideas',
  'Deep stories',
  'Mix of both',
];

const kIdeaGoals = [3, 5, 10, 15];

const _topicSearchQueries = <String, List<String>>{
  'Psychology': ['psychology', 'mind', 'mental'],
  'Business & Money': [
    'business',
    'money',
    'economics',
    'finance',
    'entrepreneurship',
  ],
  'Science': ['science', 'physics', 'biology', 'chemistry', 'astronomy'],
  'Technology': [
    'technology',
    'computer',
    'software',
    'programming',
    'artificial intelligence',
  ],
  'Philosophy': ['philosophy', 'ethics', 'stoicism'],
  'Health': ['health', 'fitness', 'nutrition', 'medicine'],
  'History': ['history', 'ancient', 'biography', 'war'],
  'Art & Design': ['art', 'design', 'music', 'creativity'],
  'Productivity': ['productivity', 'habit', 'focus', 'management', 'time'],
  'Personal Growth': ['self-help', 'motivation', 'success', 'personal'],
};

String? topicSearchQuery(String? topic) {
  if (topic == null) return null;
  return _topicSearchQueries[topic]?.first;
}

bool matchesPreferences(ExploreContent item, List<String> topics) {
  if (topics.isEmpty) return true;
  final haystacks = [
    if (item.category != null) item.category!.toLowerCase(),
    item.title.toLowerCase(),
    ...item.subjects.map((s) => s.toLowerCase()),
  ];
  for (final topic in topics) {
    final keywords = _topicSearchQueries[topic] ?? [topic.toLowerCase()];
    if (haystacks.any((h) => keywords.any((k) => h.contains(k)))) {
      return true;
    }
  }
  return false;
}
