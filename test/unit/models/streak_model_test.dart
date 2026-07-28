import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/data/models/streak_model.dart';
import '../../helpers/test_data.dart';

void main() {
  group('StreakModel', () {
    test('fromJson creates model correctly', () {
      final model = StreakModel.fromJson(streakJson);

      expect(model.id, 's0000001-0000-0000-0000-000000000001');
      expect(model.profileId, 'p0000001-0000-0000-0000-000000000001');
      expect(model.currentStreak, 5);
      expect(model.longestStreak, 10);
      expect(model.totalLearningDays, 25);
    });

    test('fromJson handles null lastActivityDate', () {
      final json = {
        'id': 'test-id',
        'profile_id': 'profile-id',
      };
      final model = StreakModel.fromJson(json);

      expect(model.currentStreak, 0);
      expect(model.longestStreak, 0);
      expect(model.lastActivityDate, isNull);
      expect(model.totalLearningDays, 0);
    });
  });
}
