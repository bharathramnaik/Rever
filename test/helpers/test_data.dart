import 'package:rever/src/data/models/topic_model.dart';
import 'package:rever/src/data/models/concept_model.dart';
import 'package:rever/src/data/models/learning_object_model.dart';
import 'package:rever/src/data/models/profile_model.dart';
import 'package:rever/src/data/models/streak_model.dart';

final testTopic = TopicModel(
  id: 't0000001-0000-0000-0000-000000000001',
  name: 'Technology',
  slug: 'technology',
  description: 'Computers, software, and digital systems',
  icon: 'code',
  color: '#6C63FF',
  sortOrder: 1,
);

final testTopics = List.generate(3, (i) => TopicModel(
  id: 't${i.toString().padLeft(7, '0')}-0000-0000-0000-00000000000${i + 1}',
  name: ['Technology', 'Science', 'Mathematics'][i],
  slug: ['technology', 'science', 'mathematics'][i],
  description: 'Description $i',
  icon: ['code', 'biotech', 'calculate'][i],
  color: ['#6C63FF', '#00D9A6', '#FF6B6B'][i],
  sortOrder: i + 1,
));

final testConcept = ConceptModel(
  id: 'c0000001-0001-0000-0000-000000000001',
  title: 'How Transformers Work',
  slug: 'how-transformers-work',
  summary: 'Transformers are a neural network architecture that revolutionized AI.',
  difficulty: 'beginner',
  estimatedMinutes: 8,
  createdAt: DateTime.now(),
);

final testConcepts = List.generate(3, (i) => ConceptModel(
  id: 'c0000001-0001-0000-0000-00000000000${i + 1}',
  title: 'Concept ${i + 1}',
  slug: 'concept-${i + 1}',
  summary: 'Summary $i',
  difficulty: 'beginner',
  estimatedMinutes: 5 + i * 2,
  createdAt: DateTime.now(),
));

final testQuizContent = {
  'questions': [
    {
      'question': 'What year was the transformer architecture introduced?',
      'options': ['2015', '2017', '2019', '2021'],
      'correct_index': 1,
    },
    {
      'question': 'Test question 2?',
      'options': ['A', 'B', 'C', 'D'],
      'correct_index': 2,
    },
  ],
};

final testCardContent = {
  'body': 'Test body content for a learning card.',
  'key_points': ['Point 1', 'Point 2', 'Point 3'],
};

final testLearningObjectCard = LearningObjectModel(
  id: 'l0000001-0000-0000-0000-000000000001',
  conceptId: 'c0000001-0001-0000-0000-000000000001',
  objectType: 'card',
  title: 'Transformer Architecture',
  content: testCardContent,
  difficulty: 'beginner',
  estimatedDuration: 120,
);

final testLearningObjectQuiz = LearningObjectModel(
  id: 'l0000001-0000-0000-0000-000000000002',
  conceptId: 'c0000001-0001-0000-0000-000000000001',
  objectType: 'quiz',
  title: 'Transformer Quick Quiz',
  content: testQuizContent,
  difficulty: 'beginner',
  estimatedDuration: 180,
);

final testLearningObjects = [testLearningObjectCard, testLearningObjectQuiz];

final testProfile = ProfileModel(
  id: 'p0000001-0000-0000-0000-000000000001',
  accountId: 'a0000001-0000-0000-0000-000000000001',
  name: 'Test User',
  avatarUrl: null,
  profileType: 'adult',
  ageRange: '18+',
  dailyGoalMinutes: 10,
);

final testStreak = StreakModel(
  id: 's0000001-0000-0000-0000-000000000001',
  profileId: 'p0000001-0000-0000-0000-000000000001',
  currentStreak: 5,
  longestStreak: 10,
  lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
  totalLearningDays: 25,
);

final topicJson = {
  'id': 't0000001-0000-0000-0000-000000000001',
  'name': 'Technology',
  'slug': 'technology',
  'description': 'Computers, software, and digital systems',
  'icon': 'code',
  'color': '#6C63FF',
  'sort_order': 1,
};

final conceptJson = {
  'id': 'c0000001-0001-0000-0000-000000000001',
  'title': 'How Transformers Work',
  'slug': 'how-transformers-work',
  'summary': 'Transformers are a neural network architecture that revolutionized AI.',
  'difficulty': 'beginner',
  'estimated_minutes': 8,
  'created_at': DateTime.now().toIso8601String(),
};

final learningObjectJson = {
  'id': 'l0000001-0000-0000-0000-000000000001',
  'concept_id': 'c0000001-0001-0000-0000-000000000001',
  'object_type': 'card',
  'title': 'Transformer Architecture',
  'content': testCardContent,
  'difficulty': 'beginner',
  'estimated_duration': 120,
};

final profileJson = {
  'id': 'p0000001-0000-0000-0000-000000000001',
  'account_id': 'a0000001-0000-0000-0000-000000000001',
  'name': 'Test User',
  'avatar_url': null,
  'profile_type': 'adult',
  'age_range': '18+',
  'daily_goal_minutes': 10,
};

final streakJson = {
  'id': 's0000001-0000-0000-0000-000000000001',
  'profile_id': 'p0000001-0000-0000-0000-000000000001',
  'current_streak': 5,
  'longest_streak': 10,
  'last_activity_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10),
  'total_learning_days': 25,
};
