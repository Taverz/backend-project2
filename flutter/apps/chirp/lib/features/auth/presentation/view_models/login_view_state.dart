import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

/// Plain Dart state экрана логина — без зависимостей от Bloc/Cubit/Stream.
/// UI знает только этот тип; конкретный state-manager под ним — деталь импла VM.
class LoginViewState extends Equatable {
  const LoginViewState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.failure,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final Failure? failure;

  static const initial = LoginViewState();

  LoginViewState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    Failure? failure,
    bool clearFailure = false,
  }) => LoginViewState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSuccess: isSuccess ?? this.isSuccess,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [isSubmitting, isSuccess, failure];
}
