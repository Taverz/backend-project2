import 'package:dio/dio.dart';
import '../../session/session_controller.dart';
import '../../session/session_state.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._session);

  final SessionController _session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final s = _session.state;
    if (s is SessionAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${s.accessToken}';
    }
    handler.next(options);
  }
}
