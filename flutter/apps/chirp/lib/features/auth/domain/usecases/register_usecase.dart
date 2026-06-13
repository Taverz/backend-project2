import '../../../../core/session/session_controller.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository, this._session);

  final AuthRepository _repository;
  final SessionController _session;

  Future<void> call({
    required String username,
    required String email,
    required String password,
  }) async {
    final tokens = await _repository.register(
      username: username,
      email: email,
      password: password,
    );
    await _session.update(
      accessToken: tokens.access,
      refreshToken: tokens.refresh,
    );
  }
}
