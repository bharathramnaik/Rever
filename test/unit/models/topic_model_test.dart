import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/data/models/topic_model.dart';
import '../../helpers/test_data.dart';

void main() {
  group('TopicModel', () {
    test('fromJson creates model correctly', () {
      final model = TopicModel.fromJson(topicJson);

      expect(model.id, 't0000001-0000-0000-0000-000000000001');
      expect(model.name, 'Technology');
      expect(model.slug, 'technology');
      expect(model.description, 'Computers, software, and digital systems');
      expect(model.icon, 'code');
      expect(model.color, '#6C63FF');
      expect(model.sortOrder, 1);
    });

    test('fromJson handles null fields', () {
      final json = {
        'id': 'test-id',
        'name': 'Test',
        'slug': 'test',
        'sort_order': null,
      };
      final model = TopicModel.fromJson(json);

      expect(model.id, 'test-id');
      expect(model.name, 'Test');
      expect(model.slug, 'test');
      expect(model.description, isNull);
      expect(model.icon, isNull);
      expect(model.color, isNull);
      expect(model.sortOrder, 0);
    });

    test('sortOrder defaults to 0 when missing', () {
      final json = {
        'id': 'test-id',
        'name': 'Test',
        'slug': 'test',
      };
      final model = TopicModel.fromJson(json);
      expect(model.sortOrder, 0);
    });

    test('const constructor works', () {
      const model = TopicModel(
        id: 'id',
        name: 'name',
        slug: 'slug',
      );
      expect(model.id, 'id');
      expect(model.name, 'name');
    });
  });
}
