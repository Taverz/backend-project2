import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/error/exceptions.dart';
import 'package:chirp/core/network/interceptors/error_interceptor.dart';

/// Тестовый handler — захватывает то, с чем был вызван reject() или next().
class _CapturingHandler extends ErrorInterceptorHandler {
  DioException? rejected;
  DioException? nexted;

  @override
  void reject(DioException error, {bool callFollowingErrorInterceptor = false}) {
    rejected = error;
  }

  @override
  void next(DioException err) {
    nexted = err;
  }

  @override
  void resolve(Response response) {}
}

DioException _makeError({
  int? statusCode,
  Map<String, dynamic>? body,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final opts = RequestOptions(path: '/test');
  return DioException(
    requestOptions: opts,
    response: statusCode != null
        ? Response(requestOptions: opts, statusCode: statusCode, data: body)
        : null,
    type: type,
  );
}

void main() {
  late ErrorInterceptor interceptor;

  setUp(() => interceptor = ErrorInterceptor());

  test('401 → UnauthorizedException', () {
    final handler = _CapturingHandler();
    interceptor.onError(_makeError(statusCode: 401), handler);
    expect(handler.rejected?.error, isA<UnauthorizedException>());
  });

  test('404 → ApiException(404)', () {
    final handler = _CapturingHandler();
    interceptor.onError(_makeError(statusCode: 404), handler);
    expect(handler.rejected?.error, isA<ApiException>());
    expect((handler.rejected!.error as ApiException).statusCode, 404);
  });

  test('500 → ApiException(500)', () {
    final handler = _CapturingHandler();
    interceptor.onError(_makeError(statusCode: 500), handler);
    expect(handler.rejected?.error, isA<ApiException>());
    expect((handler.rejected!.error as ApiException).statusCode, 500);
  });

  test('connectionError → NetworkException', () {
    final handler = _CapturingHandler();
    interceptor.onError(
      _makeError(type: DioExceptionType.connectionError),
      handler,
    );
    expect(handler.rejected?.error, isA<NetworkException>());
  });

  test('receiveTimeout → NetworkException', () {
    final handler = _CapturingHandler();
    interceptor.onError(
      _makeError(type: DioExceptionType.receiveTimeout),
      handler,
    );
    expect(handler.rejected?.error, isA<NetworkException>());
  });

  test('тело ответа с полем error используется как message', () {
    final handler = _CapturingHandler();
    interceptor.onError(
      _makeError(statusCode: 422, body: {'error': 'validation failed'}),
      handler,
    );
    final err = handler.rejected?.error as ApiException;
    expect(err.message, 'validation failed');
  });

  test('неизвестный тип ошибки передаётся дальше через next()', () {
    final handler = _CapturingHandler();
    interceptor.onError(
      _makeError(type: DioExceptionType.cancel),
      handler,
    );
    expect(handler.nexted, isNotNull);
    expect(handler.rejected, isNull);
  });
}
