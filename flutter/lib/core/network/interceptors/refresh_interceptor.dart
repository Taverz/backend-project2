import 'dart:async';
import 'package:dio/dio.dart';
import '../../error/exceptions.dart';
import '../../session/session_controller.dart';
import '../../session/session_state.dart';
import '../endpoints.dart';

/// Single-flight refresh: при 401 стартует один refresh-запрос,
/// все остальные 401 ждут его результата, затем повторяют исходный запрос.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({required this.session, required this.dio});

  final SessionController session;
  final Dio dio;

  Completer<bool>? _refreshCompleter;

  @override
  // ignore: avoid_void_async — переопределяет Interceptor.onError (void обязателен)
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.error is! UnauthorizedException) {
      handler.next(err);
      return;
    }

    // Не пытаемся рефрешить сам refresh-запрос.
    if (err.requestOptions.path == Endpoints.refresh) {
      await session.drop();
      handler.next(err);
      return;
    }

    final success = await _refresh();
    if (!success) {
      handler.next(err);
      return;
    }

    // Повторяем исходный запрос с новым токеном.
    // Читаем состояние заново — оно могло измениться пока шёл refresh.
    try {
      final s = session.state;
      if (s is! SessionAuthenticated) {
        handler.next(err);
        return;
      }
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${s.accessToken}';
      final response = await dio.fetch(opts);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final s = session.state;
      if (s is! SessionAuthenticated) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await dio.post(
        Endpoints.refresh,
        data: {'refresh_token': s.refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      await session.update(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      _refreshCompleter!.complete(true);
      return true;
    } catch (_) {
      await session.drop();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
