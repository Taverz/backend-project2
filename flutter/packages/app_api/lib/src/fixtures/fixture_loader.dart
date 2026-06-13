import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// Загружает JSON-фикстуры из `packages/app_api/fixtures/`.
///
/// Один источник для трёх потребителей:
/// - тесты мапперов/репозиториев (`expect(jsonDecode(load(...)), ...)`);
/// - `MockAppApiClientImpl` — оффлайн-режим разработки (`--dart-define=USE_MOCK_API=true`);
/// - живая документация контракта в git.
///
/// Из-под `flutter test` грузим через `rootBundle` (требует
/// `TestWidgetsFlutterBinding.ensureInitialized()`); если binding недоступен —
/// пытаемся прочитать файл напрямую через `dart:io` (для чистых Dart-тестов).
abstract final class FixtureLoader {
  static const _packagePath = 'packages/app_api/fixtures';

  /// Возвращает декодированный JSON по пути относительно `fixtures/`.
  /// Пример: `await FixtureLoader.loadJson('auth/login_response.json')`.
  static Future<Map<String, dynamic>> loadJson(String relativePath) async {
    final raw = await _loadString(relativePath);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<String> loadString(String relativePath) => _loadString(
    relativePath,
  );

  static Future<String> _loadString(String relativePath) async {
    try {
      return await rootBundle.loadString('$_packagePath/$relativePath');
    } catch (_) {
      final file = File('packages/app_api/fixtures/$relativePath');
      if (await file.exists()) return file.readAsString();
      rethrow;
    }
  }
}
