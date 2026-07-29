import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppIconService {
  AppIconService._();

  static const _channel = MethodChannel('com.rever.rever/app_icon');

  static Future<void> setIcon(String variant) async {
    try {
      await _channel.invokeMethod('setAppIcon', {'variant': variant});
    } catch (e) {
      debugPrint('[AppIcon] Failed to set icon: $e');
    }
  }
}
