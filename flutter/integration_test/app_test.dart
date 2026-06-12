// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chirp/main.dart' as app;

/// Integration-тесты запускаются на реальном устройстве / эмуляторе:
///   flutter test integration_test/ -d <device_id>
///
/// Тесты проверяют поведение всего приложения целиком:
/// запуск, redirect по сессии, базовый UI.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App startup', () {
    testWidgets('приложение запускается без краша', (tester) async {
      app.main();
      // Ждём первого фрейма
      await tester.pump();
      // Ждём завершения асинхронной инициализации (session.init + DI)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Приложение должно отрендерить хоть что-то
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets(
      'незалогиненный пользователь видит экран логина',
      (tester) async {
        // Свежий запуск без сохранённых токенов (чистый эмулятор/симулятор)
        app.main();
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // GoRouter должен отредиректить на /login (SessionUnauthenticated)
        // Ищем текст-заглушку, добавленную в app_router.dart
        expect(find.textContaining('Login'), findsOneWidget);
      },
    );
  });
}
