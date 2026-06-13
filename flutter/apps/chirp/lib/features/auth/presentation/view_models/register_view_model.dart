import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bloc/register_bloc.dart';
import 'register_view_state.dart';

abstract interface class RegisterViewModel {
  ValueListenable<RegisterViewState> get state;
  Future<void> submit({
    required String username,
    required String email,
    required String password,
  });
  void dispose();
}

class BlocRegisterViewModel implements RegisterViewModel {
  BlocRegisterViewModel(this._bloc) {
    _state = ValueNotifier<RegisterViewState>(_mapState(_bloc.state));
    _subscription = _bloc.stream.listen((blocState) {
      _state.value = _mapState(blocState);
    });
  }

  final RegisterBloc _bloc;
  late final ValueNotifier<RegisterViewState> _state;
  late final StreamSubscription<RegisterState> _subscription;

  @override
  ValueListenable<RegisterViewState> get state => _state;

  @override
  Future<void> submit({
    required String username,
    required String email,
    required String password,
  }) async {
    _bloc.add(
      RegisterSubmitted(
        username: username,
        email: email,
        password: password,
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _state.dispose();
  }

  RegisterViewState _mapState(RegisterState blocState) => switch (blocState) {
    RegisterInitial() => RegisterViewState.initial,
    RegisterInProgress() => const RegisterViewState(isSubmitting: true),
    RegisterSuccess() => const RegisterViewState(isSuccess: true),
    RegisterFailureState(:final failure) =>
      RegisterViewState(failure: failure),
  };
}
