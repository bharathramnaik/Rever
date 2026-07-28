import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/data/models/learning_object_model.dart';
import '../../helpers/test_data.dart';

void main() {
  group('LearningObjectModel', () {
    test('fromJson creates card model correctly', () {
      final model = LearningObjectModel.fromJson(learningObjectJson);

      expect(model.id, 'l0000001-0000-0000-0000-000000000001');
      expect(model.conceptId, 'c0000001-0001-0000-0000-000000000001');
      expect(model.objectType, 'card');
      expect(model.title, 'Transformer Architecture');
      expect(model.content['body'], isNotEmpty);
      expect(model.difficulty, 'beginner');
      expect(model.estimatedDuration, 120);
    });

    test('fromJson handles null estimatedDuration', () {
      final json = {
        'id': 'test-id',
        'concept_id': 'concept-id',
        'object_type': 'quiz',
        'title': 'Quiz',
        'content': {'questions': []},
      };
      final model = LearningObjectModel.fromJson(json);

      expect(model.estimatedDuration, isNull);
      expect(model.difficulty, 'beginner');
    });
  });
}
