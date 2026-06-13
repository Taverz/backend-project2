import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chirp/core/error/exceptions.dart';
import 'package:chirp/core/network/endpoints.dart';
import 'package:chirp/core/network/interceptors/refresh_interceptor.dart';
import 'package:chirp/core/session/session_controller.dart';
import 'package:chirp/core/session/session_state.dart';
import 'package:chirp/core/session/token_storage.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Handler, который завершает [resultFuture] когда вызван любой метод resolve/reject/next.
class _CompletingHandler extends ErrorInterceptorHandler {
  final _completer = Completer<_HandlerResult>();

  // Нельзя переопределять `future` из Dio (тип InterceptorState не совместим).
  Future<_HandlerResult> get resultFuture => _completer.future;

  @override
  void resolve(Response<Object?> response) =>
      _completer.complete(_HandlerResult.resolved(response));

  @override
  void reject(
    DioException error, {
    bool callFollowingErrorInterceptor = false,
  }) => _completer.complete(_HandlerResult.rejected(error));

  @override
  void next(DioException err) =>
      _completer.complete(_HandlerResult.nexted(err));
}

enum _HandlerOutcome { resolved, rejected, nexted }

class _HandlerResult {
  const _HandlerResult._(this.outcome, {this.response, this.error});
  factory _HandlerResult.resolved(Response<Object?> r) =>
      _HandlerResult._(_HandlerOutcome.resolved, response: r);
  factory _HandlerResult.rejected(DioException e) =>
      _HandlerResult._(_HandlerOutcome.rejected, error: e);
  factory _HandlerResult.nexted(DioException e) =>
      _HandlerResult._(_HandlerOutcome.nexted, error: e);

  final _HandlerOutcome outcome;
  final Response<Object?>? response;
  final DioException? error;

  bool get wasResolved => outcome == _HandlerOutcome.resolved;
  bool get wasRejected => outcome == _HandlerOutcome.rejected;
  bool get wasNexted => outcome == _HandlerOutcome.nexted;
}

// ── Setup helpers ─────────────────────────────────────────────────────────────

DioException _make401(String path) {
  final opts = RequestOptions(path: path);
  return DioException(
    requestOptions: opts,
    response: Response(requestOptions: opts, statusCode: 401),
    error: const UnauthorizedException(),
    type: DioExceptionType.badResponse,
  );
}

DioException _makeNetworkError(String path) {
  final opts = RequestOptions(path: path);
  return DioException(
    requestOptions: opts,
    error: const NetworkException(),
    type: DioExceptionType.connectionError,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockTokenStorage storage;
  late SessionController session;

  // Dio используется RefreshInterceptor для POST /auth/refresh и fetch() retry.
  // Контролируем «ответы сервера» через InterceptorsWrapper.
  late Dio dio;
  late RefreshInterceptor interceptor;

  // Счётчики и флаги для управления поведением «сервера» в тестах.
  late int refreshCallCount;
  late bool refreshShouldFail;

  Future<void> setupSession({bool authenticated = true}) async {
    if (authenticated) {
      when(
        () => storage.write(
          access: any(named: 'access'),
          refresh: any(named: 'refresh'),
        ),
      ).thenAnswer((_) async {});
      await session.update(
        accessToken: 'old_access',
        refreshToken: 'old_refresh',
      );
    } else {
      when(() => storage.read()).thenAnswer((_) async => null);
      await session.init();
    }
  }

  setUp(() async {
    storage = MockTokenStorage();
    session = SessionController(storage);

    refreshCallCount = 0;
    refreshShouldFail = false;

    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    interceptor = RefreshInterceptor(session: session, dio: dio);

    // RefreshInterceptor первым в цепи, за ним мок-сервер.
    dio.interceptors.add(interceptor);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opts, handler) async {
          if (opts.path.contains(Endpoints.refresh)) {
            refreshCallCount++;
            if (refreshShouldFail) {
              handler.reject(
                DioException(
                  requestOptions: opts,
                  response: Response(requestOptions: opts, statusCode: 401),
                  error: const UnauthorizedException(),
                  type: DioExceptionType.badResponse,
                ),
              );
            } else {
              // Небольшая задержка — нужна для теста concurrent 401.
              await Future<void>.delayed(const Duration(milliseconds: 30));
              handler.resolve(
                Response(
                  requestOptions: opts,
                  statusCode: 200,
                  data: {
                    'access_token': 'new_access',
                    'refresh_token': 'new_refresh',
                  },
                ),
              );
            }
          } else {
            // retry или обычный запрос
            handler.resolve(
              Response(requestOptions: opts, statusCode: 200, data: 'ok'),
            );
          }
        },
      ),
    );

    when(() => storage.clear()).thenAnswer((_) async {});
    when(
      () => storage.write(
        access: any(named: 'access'),
        refresh: any(named: 'refresh'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() => session.dispose());

  // ── 1. Пропускает не-401 ошибки ─────────────────────────────────────────────

  test('не-401 ошибка пробрасывается через next() без изменений', () async {
    await setupSession();

    final handler = _CompletingHandler();
    interceptor.onError(_makeNetworkError('/test'), handler);
    final result = await handler.resultFuture;

    expect(result.wasNexted, isTrue);
    expect(refreshCallCount, 0);
  });

  // ── 2. Самообращение на /refresh ─────────────────────────────────────────────

  test('401 на /auth/refresh вызывает session.drop() и next()', () async {
    await setupSession();

    final error = _make401(Endpoints.refresh);
    final handler = _CompletingHandler();
    interceptor.onError(error, handler);
    final result = await handler.resultFuture;

    expect(result.wasNexted, isTrue);
    expect(session.state, isA<SessionUnauthenticated>());
    verify(() => storage.clear()).called(1);
    expect(refreshCallCount, 0); // не пытался рефрешить
  });

  // ── 3. Успешный refresh + retry ──────────────────────────────────────────────

  test('401 → refresh успешен → retry → resolve', () async {
    await setupSession();

    final handler = _CompletingHandler();
    interceptor.onError(_make401('/api/v1/tweets'), handler);
    final result = await handler.resultFuture;

    expect(result.wasResolved, isTrue);
    expect(refreshCallCount, 1);
    // Токены обновлены
    expect(session.state, isA<SessionAuthenticated>());
    expect((session.state as SessionAuthenticated).accessToken, 'new_access');
    verify(
      () => storage.write(access: 'new_access', refresh: 'new_refresh'),
    ).called(1);
  });

  // ── 4. Неудачный refresh → drop + reject ────────────────────────────────────

  test('401 → refresh провалился → session.drop() → next()', () async {
    await setupSession();
    refreshShouldFail = true;

    final handler = _CompletingHandler();
    interceptor.onError(_make401('/api/v1/timeline'), handler);
    final result = await handler.resultFuture;

    expect(result.wasNexted, isTrue);
    expect(session.state, isA<SessionUnauthenticated>());
    verify(() => storage.clear()).called(1);
  });

  // ── 5. Unauthenticated пользователь — не пытается рефрешить ─────────────────

  test(
    '401 когда сессия Unauthenticated → session.drop(), no refresh',
    () async {
      await setupSession(authenticated: false);

      final handler = _CompletingHandler();
      interceptor.onError(_make401('/api/v1/tweets'), handler);
      final result = await handler.resultFuture;

      expect(result.wasNexted, isTrue);
      expect(refreshCallCount, 0);
    },
  );

  // ── 6. Single-flight: concurrent 401s → только один refresh ─────────────────

  test('два одновременных 401 инициируют только один refresh-запрос', () async {
    await setupSession();

    final handler1 = _CompletingHandler();
    final handler2 = _CompletingHandler();

    // Запускаем оба 401 "почти одновременно".
    // onError запускается async, _refreshCompleter устанавливается до первого await.
    // Второй вызов увидит _refreshCompleter != null и подпишется на тот же Future.
    interceptor.onError(_make401('/api/v1/tweets'), handler1);
    interceptor.onError(_make401('/api/v1/timeline'), handler2);

    final results = await Future.wait([
      handler1.resultFuture,
      handler2.resultFuture,
    ]);

    expect(refreshCallCount, 1, reason: 'single-flight: только один refresh');
    expect(results[0].wasResolved, isTrue, reason: 'первый запрос ретрайнулся');
    expect(results[1].wasResolved, isTrue, reason: 'второй запрос ретрайнулся');
  });

  // ── 7. После завершения refresh следующий 401 запускает новый цикл ───────────

  test(
    'второй 401 после завершения первого refresh запускает новый refresh',
    () async {
      await setupSession();

      // Первый цикл
      final handler1 = _CompletingHandler();
      interceptor.onError(_make401('/api/v1/tweets'), handler1);
      await handler1.resultFuture;
      expect(refreshCallCount, 1);

      // Второй цикл (после завершения первого)
      final handler2 = _CompletingHandler();
      interceptor.onError(_make401('/api/v1/timeline'), handler2);
      await handler2.resultFuture;
      expect(refreshCallCount, 2);
    },
  );
}
