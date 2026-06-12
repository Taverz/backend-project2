import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
      return;
    }

    final status = err.response?.statusCode;
    if (status != null) {
      if (status == 401) {
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
            type: err.type,
            response: err.response,
          ),
        );
        return;
      }
      final body = err.response?.data;
      final message = (body is Map ? body['error'] as String? : null) ??
          err.response?.statusMessage ??
          'Server error';
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ApiException(statusCode: status, message: message),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    handler.next(err);
  }
}
