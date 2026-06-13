import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/routes.dart';
import '../mixins/auth_form_validation_mixin.dart';
import '../scope/auth_scope.dart';
import '../view_models/register_view_model.dart';
import '../view_models/register_view_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with AuthFormValidationMixin<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameError = ValueNotifier<String?>(null);
  final _emailError = ValueNotifier<String?>(null);
  final _passwordError = ValueNotifier<String?>(null);
  final _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameError.dispose();
    _emailError.dispose();
    _passwordError.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = AuthScope.of(context).registerViewModel;
    return ValueListenableBuilder<RegisterViewState>(
      valueListenable: vm.state,
      builder: (context, state, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _obscurePassword,
          builder: (context, obscure, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: _usernameError,
              builder: (context, usernameErr, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _emailError,
                  builder: (context, emailErr, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: _passwordError,
                      builder: (context, passwordErr, _) {
                        return RegisterTemplate(
                          usernameController: _usernameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          usernameError: usernameErr,
                          emailError: emailErr,
                          passwordError: passwordErr,
                          obscurePassword: obscure,
                          isSubmitting: state.isSubmitting,
                          onSubmit: () => _onSubmit(vm),
                          onLoginTap: () => context.go(Routes.login),
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
      },
    );
  }

  void _onSubmit(RegisterViewModel vm) {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final valid = validateRegisterForm(
      username: username,
      email: email,
      password: password,
      usernameError: _usernameError,
      emailError: _emailError,
      passwordError: _passwordError,
    );
    if (!valid) return;
    vm.submit(username: username, email: email, password: password);
  }
}
