import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chirp/core/network/interceptors/auth_interceptor.dart';
import 'package:chirp/core/session/session_controller.dart';
import 'package:chirp/core/session/session_state.dart';
import 'package:chirp/core/session/token_storage.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

/// Захватывает RequestOptions из onRequest.
class _CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions options) {
    captured = options;
  }
}

void main() {
  late MockTokenStorage storage;
  late SessionController session;
  late AuthInterceptor interceptor;

  setUp(() {
    storage = MockTokenStorage();
    session = SessionController(storage);
    interceptor = AuthInterceptor(session);
  });

  tearDown(() => session.dispose());

  Future<void> _authenticate() async {
    when(() => storage.write(
          access: any(named: 'access'),
          refresh: any(named: 'refresh'),
        )).thenAnswer((_) async {});
    await session.update(accessToken: 'token_abc', refreshToken: 'ref_xyz');
  }

  test('добавляет заголовок Authorization когда пользователь вошёл', () async {
    await _authenticate();

    final opts = RequestOptions(path: '/test');
    final handler = _CapturingRequestHandler();
    interceptor.onRequest(opts, handler);

    expect(handler.captured?.headers['Authorization'], 'Bearer token_abc');
  });

  test('не добавляет заголовок в состоянии Unknown', () {
    // session ещё не инициализирован → SessionUnknown
    final opts = RequestOptions(path: '/test');
    final handler = _CapturingRequestHandler();
    interceptor.onRequest(opts, handler);

    expect(handler.captured?.headers['Authorization'], isNull);
  });

  test('не добавляет заголовок в состоянии Unauthenticated', () async {
    when(() => storage.read()).thenAnswer((_) async => null);
    await session.init(); // → Unauthenticated

    final opts = RequestOptions(path: '/test');
    final handler = _CapturingRequestHandler();
    interceptor.onRequest(opts, handler);

    expect(handler.captured?.headers['Authorization'], isNull);
  });

  test('обновляет заголовок при смене токена', () async {
    await _authenticate(); // token_abc

    when(() => storage.write(
          access: any(named: 'access'),
          refresh: any(named: 'refresh'),
        )).thenAnswer((_) async {});
    await session.update(accessToken: 'new_token', refreshToken: 'new_ref');

    final opts = RequestOptions(path: '/test');
    final handler = _CapturingRequestHandler();
    interceptor.onRequest(opts, handler);

    expect(handler.captured?.headers['Authorization'], 'Bearer new_token');
  });

  test('не модифицирует другие заголовки', () async {
    await _authenticate();

    final opts = RequestOptions(
      path: '/test',
      headers: {'X-Custom': 'value'},
    );
    final handler = _CapturingRequestHandler();
    interceptor.onRequest(opts, handler);

    expect(handler.captured?.headers['X-Custom'], 'value');
    expect(handler.captured?.headers['Authorization'], 'Bearer token_abc');
  });
}
