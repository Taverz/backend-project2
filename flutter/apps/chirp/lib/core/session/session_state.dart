sealed class SessionState {
  const SessionState();
}

/// Токены ещё не прочитаны из хранилища (splash-стейт).
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

/// Токены есть — пользователь вошёл.
final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated({
    required this.accessToken,
    required this.refreshToken,
  });
  final String accessToken;
  final String refreshToken;
}

/// Токенов нет — нужен логин.
final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}
