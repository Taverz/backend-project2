// ignore_for_file: avoid_print
//
// Перезаписывает фикстуры `packages/app_api/fixtures/<feature>/*_response.json`
// реальными ответами живого бэкенда. `*_request.json` отправляются как тело
// запросов — их редактируешь руками (это «эталонный» вход для эндпоинта).
//
// Запуск (из корня монорепо или из packages/app_api):
//   dart run tool/refresh_fixtures.dart \
//     --api-url=http://localhost:8080 \
//     [--only=auth/login,auth/register]
//
// Скрипт работает через `dart:io HttpClient` — Flutter не нужен.
// Если эндпоинт требует авторизации, добавь его в `Endpoint(needsAuth: true)`;
// тогда скрипт сначала логинится через `auth/login_request.json` и переиспользует
// access-token в Authorization-заголовке.

import 'dart:convert';
import 'dart:io';

/// Описание одного эндпоинта для записи фикстуры.
class Endpoint {
  const Endpoint({
    required this.fixturePath,
    required this.method,
    required this.url,
    this.needsAuth = false,
  });

  /// Относительный путь без расширения: `auth/login` →
  /// `fixtures/auth/login_request.json` + `fixtures/auth/login_response.json`.
  final String fixturePath;
  final String method;
  final String url;
  final bool needsAuth;
}

/// Каталог известных эндпоинтов. Добавлять сюда при каждой новой ручке.
const _endpoints = <Endpoint>[
  Endpoint(
    fixturePath: 'auth/login',
    method: 'POST',
    url: '/api/v1/auth/login',
  ),
  Endpoint(
    fixturePath: 'auth/register',
    method: 'POST',
    url: '/api/v1/auth/register',
  ),
];

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final fixturesDir = await _findFixturesDir();
  final client = HttpClient();
  String? accessToken;

  final targets = options.only.isEmpty
      ? _endpoints
      : _endpoints.where((e) => options.only.contains(e.fixturePath));

  for (final endpoint in targets) {
    final requestFile = File(
      '${fixturesDir.path}/${endpoint.fixturePath}_request.json',
    );
    final responseFile = File(
      '${fixturesDir.path}/${endpoint.fixturePath}_response.json',
    );

    if (!await requestFile.exists()) {
      print('SKIP ${endpoint.fixturePath}: request-фикстура не найдена');
      continue;
    }

    final body = await requestFile.readAsString();
    final uri = Uri.parse('${options.apiUrl}${endpoint.url}');
    try {
      final response = await _send(
        client,
        method: endpoint.method,
        uri: uri,
        body: body,
        accessToken: endpoint.needsAuth ? accessToken : null,
      );

      if (response.statusCode >= 400) {
        print(
          'FAIL ${endpoint.fixturePath}: HTTP ${response.statusCode} — фикстура НЕ обновлена',
        );
        print('     body: ${response.body}');
        continue;
      }

      // Прогоняем через jsonDecode/encode чтобы отформатировать единообразно.
      final decoded = jsonDecode(response.body);
      const encoder = JsonEncoder.withIndent('  ');
      await responseFile.writeAsString('${encoder.convert(decoded)}\n');
      print('OK   ${endpoint.fixturePath} → ${responseFile.path}');

      // После логина запоминаем токен — он понадобится для needsAuth-эндпоинтов.
      if (endpoint.fixturePath == 'auth/login' && decoded is Map) {
        accessToken = decoded['access_token'] as String?;
      }
    } catch (e) {
      print('ERR  ${endpoint.fixturePath}: $e');
    }
  }

  client.close();
}

class _Options {
  _Options({required this.apiUrl, required this.only});
  final String apiUrl;
  final Set<String> only;
}

_Options _parseArgs(List<String> args) {
  var apiUrl = 'http://localhost:8080';
  final only = <String>{};
  for (final arg in args) {
    if (arg.startsWith('--api-url=')) {
      apiUrl = arg.substring('--api-url='.length);
    } else if (arg.startsWith('--only=')) {
      only.addAll(arg.substring('--only='.length).split(','));
    }
  }
  return _Options(apiUrl: apiUrl, only: only);
}

Future<Directory> _findFixturesDir() async {
  // Скрипт можно запускать из корня монорепо или из packages/app_api/.
  for (final candidate in [
    'fixtures',
    'packages/app_api/fixtures',
    'flutter/packages/app_api/fixtures',
  ]) {
    final dir = Directory(candidate);
    if (await dir.exists()) return dir;
  }
  throw StateError(
    'fixtures/ не найдена. Запускай из корня монорепо или из packages/app_api/.',
  );
}

class _Response {
  _Response(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

Future<_Response> _send(
  HttpClient client, {
  required String method,
  required Uri uri,
  required String body,
  String? accessToken,
}) async {
  final request = await client.openUrl(method, uri);
  request.headers.contentType = ContentType.json;
  if (accessToken != null) {
    request.headers.add('Authorization', 'Bearer $accessToken');
  }
  request.write(body);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  return _Response(response.statusCode, responseBody);
}
