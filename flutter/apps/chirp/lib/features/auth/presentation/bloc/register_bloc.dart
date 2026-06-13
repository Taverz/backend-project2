import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/register_usecase.dart';

// ── Bloc ──────────────────────────────────────────────────────────────────────

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._registerUseCase) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final RegisterUseCase _registerUseCase;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (state is RegisterInProgress) return;
    emit(const RegisterInProgress());
    try {
      await _registerUseCase(
        username: event.username,
        email: event.email,
        password: event.password,
      );
      emit(const RegisterSuccess());
    } on Failure catch (failure) {
      emit(RegisterFailureState(failure));
    } catch (_) {
      emit(const RegisterFailureState(UnknownFailure()));
    }
  }
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object?> get props => [];
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterInProgress extends RegisterState {
  const RegisterInProgress();
}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

final class RegisterFailureState extends RegisterState {
  const RegisterFailureState(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

// ── Events ────────────────────────────────────────────────────────────────────

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.username,
    required this.email,
    required this.password,
  });
  final String username;
  final String email;
  final String password;

  @override
  List<Object?> get props => [username, email, password];
}
