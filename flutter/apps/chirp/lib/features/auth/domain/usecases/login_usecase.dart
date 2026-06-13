import '../../../../core/session/session_controller.dart';
import '../repositories/auth_repository.dart';

/// Оркестрирует логин: repo.login() + SessionController.update().
/// При ошибке бросает `Failure` наверх (вызывающий Bloc ловит).
class LoginUseCase {
  const LoginUseCase(this._repository, this._session);

  final AuthRepository _repository;
  final SessionController _session;

  Future<void> call({required String email, required String password}) async {
    final tokens = await _repository.login(email: email, password: password);
    await _session.update(
      accessToken: tokens.access,
      refreshToken: tokens.refresh,
    );
  }
}
