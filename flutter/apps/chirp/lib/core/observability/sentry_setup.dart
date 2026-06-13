import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Точка инициализации Sentry. DSN и окружение приходят из `--dart-define`:
/// `flutter run --dart-define=SENTRY_DSN=https://... --dart-define=APP_ENV=dev`.
/// Если DSN не задан (локальная разработка) — приложение просто запускается
/// через `runAppRunner` без Sentry-обёртки.
abstract final class SentrySetup {
  static const _dsn = String.fromEnvironment('SENTRY_DSN');
  static const _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  static const _release = String.fromEnvironment(
    'APP_RELEASE',
    defaultValue: 'chirp@dev',
  );

  /// Оборачивает `runApp` в Sentry-zone (или запускает напрямую, если DSN пуст).
  static Future<void> bootstrap(FutureOr<void> Function() runAppRunner) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (_dsn.isEmpty) {
      await runAppRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.environment = _environment;
        options.release = _release;
        options.tracesSampleRate = 0.1;
        options.attachScreenshot = false;
      },
      appRunner: () async => runAppRunner(),
    );
  }
}
