import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/data/models/profile_model.dart';
import '../../helpers/test_data.dart';

void main() {
  group('ProfileModel', () {
    test('fromJson creates model correctly', () {
      final model = ProfileModel.fromJson(profileJson);

      expect(model.id, 'p0000001-0000-0000-0000-000000000001');
      expect(model.accountId, 'a0000001-0000-0000-0000-000000000001');
      expect(model.name, 'Test User');
      expect(model.profileType, 'adult');
      expect(model.dailyGoalMinutes, 10);
    });

    test('fromJson handles null fields', () {
      final json = {
        'id': 'test-id',
        'account_id': 'account-id',
        'name': 'Test',
      };
      final model = ProfileModel.fromJson(json);

      expect(model.avatarUrl, isNull);
      expect(model.profileType, 'adult');
      expect(model.dailyGoalMinutes, 10);
    });
  });
}
