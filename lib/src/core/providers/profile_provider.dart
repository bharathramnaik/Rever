import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveProfileIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final activeProfileIdProvider =
    NotifierProvider<ActiveProfileIdNotifier, String?>(
  ActiveProfileIdNotifier.new,
);
