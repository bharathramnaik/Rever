import 'package:logger/logger.dart';

/// Shared app-wide logger. Use this instead of print() or bare catch blocks.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);
