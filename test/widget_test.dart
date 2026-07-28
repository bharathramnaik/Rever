import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rever/src/app/app.dart';

void main() {
  testWidgets('Rever app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: ReverApp(),
    ));
  });
}
