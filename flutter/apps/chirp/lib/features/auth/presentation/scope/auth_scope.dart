import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/di/app_scope.dart';
import '../bloc/login_bloc.dart';
import '../bloc/register_bloc.dart';
import '../view_models/login_view_model.dart';
import '../view_models/register_view_model.dart';

/// Scope фичи Auth: владеет Bloc'ами + ViewModel'ями и сам слушает
/// `failure`-стейты VM, показывая `AppSnackBar`. Экраны не знают про Bloc —
/// они получают `LoginViewModel`/`RegisterViewModel` и слушают
/// `ValueListenable<XxxViewState>`.
class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.loginViewModel,
    required this.registerViewModel,
    required super.child,
  });

  final LoginViewModel loginViewModel;
  final RegisterViewModel registerViewModel;

  static AuthScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) => false;
}

class AuthScopeHolder extends StatefulWidget {
  const AuthScopeHolder({super.key, required this.child});

  final Widget child;

  @override
  State<AuthScopeHolder> createState() => _AuthScopeHolderState();
}

class _AuthScopeHolderState extends State<AuthScopeHolder> {
  late final LoginBloc _loginBloc;
  late final RegisterBloc _registerBloc;
  late final LoginViewModel _loginVm;
  late final RegisterViewModel _registerVm;

  @override
  void initState() {
    super.initState();
    final appScope = AppScope.read(context);
    _loginBloc = LoginBloc(appScope.loginUseCase);
    _registerBloc = RegisterBloc(appScope.registerUseCase);
    _loginVm = BlocLoginViewModel(_loginBloc);
    _registerVm = BlocRegisterViewModel(_registerBloc);

    _loginVm.state.addListener(_onLoginStateChanged);
    _registerVm.state.addListener(_onRegisterStateChanged);
  }

  @override
  void dispose() {
    _loginVm.state.removeListener(_onLoginStateChanged);
    _registerVm.state.removeListener(_onRegisterStateChanged);
    _loginVm.dispose();
    _registerVm.dispose();
    _loginBloc.close();
    _registerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScope(
    loginViewModel: _loginVm,
    registerViewModel: _registerVm,
    child: widget.child,
  );

  void _onLoginStateChanged() {
    final failure = _loginVm.state.value.failure;
    if (failure != null && mounted) {
      context.showSnackBar(failure.message, isError: true);
    }
  }

  void _onRegisterStateChanged() {
    final failure = _registerVm.state.value.failure;
    if (failure != null && mounted) {
      context.showSnackBar(failure.message, isError: true);
    }
  }
}
