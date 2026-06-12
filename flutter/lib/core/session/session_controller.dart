import 'dart:async';
import 'package:flutter/foundation.dart';
import 'session_state.dart';
import 'token_storage.dart';

/// Единственный источник истины о сессии.
/// Живёт в AppScope. Без Flutter-зависимостей, тестируется как чистый Dart.
class SessionController {
  SessionController(this._storage);

  final TokenStorage _storage;

  final _stateNotifier = ValueNotifier<SessionState>(const SessionUnknown());
  final _stateController = StreamController<SessionState>.broadcast();

  SessionState get state => _stateNotifier.value;
  ValueListenable<SessionState> get listenable => _stateNotifier;
  Stream<SessionState> get stream => _stateController.stream;

  /// Вызывается один раз при старте приложения.
  Future<void> init() async {
    final tokens = await _storage.read();
    if (tokens != null) {
      _emit(SessionAuthenticated(
        accessToken: tokens.access,
        refreshToken: tokens.refresh,
      ));
    } else {
      _emit(const SessionUnauthenticated());
    }
  }

  /// RefreshInterceptor или LoginUseCase вызывает после успешного получения токенов.
  Future<void> update({required String accessToken, required String refreshToken}) async {
    await _storage.write(access: accessToken, refresh: refreshToken);
    _emit(SessionAuthenticated(
      accessToken: accessToken,
      refreshToken: refreshToken,
    ));
  }

  /// LogoutUseCase или RefreshInterceptor при 401 вызывает этот метод.
  Future<void> drop() async {
    await _storage.clear();
    _emit(const SessionUnauthenticated());
  }

  void _emit(SessionState s) {
    _stateNotifier.value = s;
    _stateController.add(s);
  }

  void dispose() {
    _stateNotifier.dispose();
    _stateController.close();
  }
}
