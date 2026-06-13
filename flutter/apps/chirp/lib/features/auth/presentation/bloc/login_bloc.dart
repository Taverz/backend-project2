import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/login_usecase.dart';

// ── Bloc ──────────────────────────────────────────────────────────────────────

/// Bloc живёт только ради внешнего вызова — login через UseCase.
/// Локальный UI-стейт формы (тексты, видимость пароля, ошибки полей) —
/// в виджете через ValueNotifier'ы, не здесь.
/// Никогда не импортируется экранами напрямую — между ним и UI стоит
/// `LoginViewModel` (см. [[../view_models/login_view_model.dart]]).
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUseCase _loginUseCase;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginInProgress) return;
    emit(const LoginInProgress());
    try {
      await _loginUseCase(email: event.email, password: event.password);
      emit(const LoginSuccess());
    } on Failure catch (failure) {
      emit(LoginFailureState(failure));
    } catch (_) {
      emit(const LoginFailureState(UnknownFailure()));
    }
  }
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginInProgress extends LoginState {
  const LoginInProgress();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

final class LoginFailureState extends LoginState {
  const LoginFailureState(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

// ── Events ────────────────────────────────────────────────────────────────────

sealed class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
