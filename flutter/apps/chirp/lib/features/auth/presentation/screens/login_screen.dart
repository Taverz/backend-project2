import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/routes.dart';
import '../mixins/auth_form_validation_mixin.dart';
import '../scope/auth_scope.dart';
import '../view_models/login_view_model.dart';
import '../view_models/login_view_state.dart';

/// Container/controller. Берёт VM из AuthScope, держит controllers и notifier'ы
/// для локального стейта формы, прокидывает callbacks в `LoginTemplate` (ui_kit).
/// Весь UI — в template'е; здесь только wiring.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AuthFormValidationMixin<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailError = ValueNotifier<String?>(null);
  final _passwordError = ValueNotifier<String?>(null);
  final _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailError.dispose();
    _passwordError.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = AuthScope.of(context).loginViewModel;
    return ValueListenableBuilder<LoginViewState>(
      valueListenable: vm.state,
      builder: (context, state, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _obscurePassword,
          builder: (context, obscure, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: _emailError,
              builder: (context, emailErr, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _passwordError,
                  builder: (context, passwordErr, _) {
                    return LoginTemplate(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      emailError: emailErr,
                      passwordError: passwordErr,
                      obscurePassword: obscure,
                      isSubmitting: state.isSubmitting,
                      onSubmit: () => _onSubmit(vm),
                      onRegisterTap: () => context.go(Routes.register),
                      onTogglePassword: () =>
                          _obscurePassword.value = !obscure,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _onSubmit(LoginViewModel vm) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final valid = validateLoginForm(
      email: email,
      password: password,
      emailError: _emailError,
      passwordError: _passwordError,
    );
    if (!valid) return;
    vm.submit(email: email, password: password);
  }
}
