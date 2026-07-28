import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/data/models/concept_model.dart';
import '../../helpers/test_data.dart';

void main() {
  group('ConceptModel', () {
    test('fromJson creates model correctly', () {
      final model = ConceptModel.fromJson(conceptJson);

      expect(model.id, 'c0000001-0001-0000-0000-000000000001');
      expect(model.title, 'How Transformers Work');
      expect(model.slug, 'how-transformers-work');
      expect(model.summary, isNotEmpty);
      expect(model.difficulty, 'beginner');
      expect(model.estimatedMinutes, 8);
    });

    test('fromJson handles null fields', () {
      final json = {
        'id': 'test-id',
        'title': 'Test',
        'slug': 'test',
        'created_at': DateTime.now().toIso8601String(),
      };
      final model = ConceptModel.fromJson(json);

      expect(model.id, 'test-id');
      expect(model.summary, isNull);
      expect(model.difficulty, 'beginner');
      expect(model.estimatedMinutes, isNull);
    });

    test('difficulty defaults to beginner', () {
      final json = {
        'id': 'test-id',
        'title': 'Test',
        'slug': 'test',
        'created_at': DateTime.now().toIso8601String(),
      };
      final model = ConceptModel.fromJson(json);
      expect(model.difficulty, 'beginner');
    });
  });
}
