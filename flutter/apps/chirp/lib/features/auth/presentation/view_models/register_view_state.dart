import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

class RegisterViewState extends Equatable {
  const RegisterViewState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.failure,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final Failure? failure;

  static const initial = RegisterViewState();

  RegisterViewState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    Failure? failure,
    bool clearFailure = false,
  }) => RegisterViewState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSuccess: isSuccess ?? this.isSuccess,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [isSubmitting, isSuccess, failure];
}
