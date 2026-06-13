import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bloc/login_bloc.dart';
import 'login_view_state.dart';

/// Контракт между UI и state-manager'ом. Экраны знают только этот интерфейс
/// и `LoginViewState` — переход с Bloc на ChangeNotifier/Riverpod/MobX
/// не меняет ни одного экранного файла.
abstract interface class LoginViewModel {
  ValueListenable<LoginViewState> get state;
  Future<void> submit({required String email, required String password});
  void dispose();
}

/// Bloc-реализация ViewModel. Подписывается на `bloc.stream`, маппит
/// `LoginState` (Bloc) → `LoginViewState` (UI), отдаёт ValueListenable.
class BlocLoginViewModel implements LoginViewModel {
  BlocLoginViewModel(this._bloc) {
    _state = ValueNotifier<LoginViewState>(_mapState(_bloc.state));
    _subscription = _bloc.stream.listen((blocState) {
      _state.value = _mapState(blocState);
    });
  }

  final LoginBloc _bloc;
  late final ValueNotifier<LoginViewState> _state;
  late final StreamSubscription<LoginState> _subscription;

  @override
  ValueListenable<LoginViewState> get state => _state;

  @override
  Future<void> submit({
    required String email,
    required String password,
  }) async {
    _bloc.add(LoginSubmitted(email: email, password: password));
  }

  @override
  void dispose() {
    _subscription.cancel();
    _state.dispose();
  }

  LoginViewState _mapState(LoginState blocState) => switch (blocState) {
    LoginInitial() => LoginViewState.initial,
    LoginInProgress() => const LoginViewState(isSubmitting: true),
    LoginSuccess() => const LoginViewState(isSuccess: true),
    LoginFailureState(:final failure) => LoginViewState(failure: failure),
  };
}
