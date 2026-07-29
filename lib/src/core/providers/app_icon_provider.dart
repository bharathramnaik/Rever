import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_icon_service.dart';

enum AppIconVariant { morning, evening }

final appIconProvider = Provider<AppIconVariant>((ref) {
  final hour = DateTime.now().hour;
  return (hour >= 6 && hour < 18) ? AppIconVariant.morning : AppIconVariant.evening;
});

Future<void> setAppIconForCurrentTime() async {
  final hour = DateTime.now().hour;
  final variant = (hour >= 6 && hour < 18) ? 'morning' : 'evening';
  await AppIconService.setIcon(variant);
}
