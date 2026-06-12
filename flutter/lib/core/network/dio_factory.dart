import 'package:dio/dio.dart';
import '../session/session_controller.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

abstract final class DioFactory {
  static Dio create({
    required String baseUrl,
    required SessionController session,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.addAll([
      LoggerInterceptor(),
      ErrorInterceptor(),
      AuthInterceptor(session),
      RefreshInterceptor(session: session, dio: dio),
    ]);

    return dio;
  }
}
