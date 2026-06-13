import '../entities/auth_tokens.dart';

/// Контракт фичи Auth. Реализация бросает `Failure` при ошибках — ловить через
/// try/catch. Никакого `Result<T>`.
abstract interface class AuthRepository {
  Future<AuthTokens> login({required String email, required String password});

  Future<AuthTokens> register({
    required String username,
    required String email,
    required String password,
  });
}
