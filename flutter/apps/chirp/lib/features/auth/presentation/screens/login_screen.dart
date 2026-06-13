import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/routes.dart';
import '../mixins/auth_form_validation_mixin.dart';
import '../scope/auth_scope.dart';
import '../view_models/login_view_model.dart';
import '../view_models/login_view_state.dart';

/// Из Material использует ТОЛЬКО `Scaffold`. Никаких `flutter_bloc` импортов —
/// UI зависит только от `LoginViewModel` и `LoginViewState`.
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppAppBar(title: 'Вход'),
            Expanded(
              child: ValueListenableBuilder<LoginViewState>(
                valueListenable: vm.state,
                builder: (context, state, _) {
                  final isSubmitting = state.isSubmitting;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        ValueListenableBuilder<String?>(
                          valueListenable: _emailError,
                          builder: (_, error, __) => AppTextField(
                            key: const Key('login_email_field'),
                            controller: _emailController,
                            label: 'Email',
                            errorText: error,
                            enabled: !isSubmitting,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            onChanged: (_) => _emailError.value = null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscurePassword,
                          builder: (_, obscure, __) =>
                              ValueListenableBuilder<String?>(
                                valueListenable: _passwordError,
                                builder: (_, error, __) => AppTextField(
                                  key: const Key('login_password_field'),
                                  controller: _passwordController,
                                  label: 'Пароль',
                                  errorText: error,
                                  enabled: !isSubmitting,
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  suffix: GestureDetector(
                                    onTap: () =>
                                        _obscurePassword.value = !obscure,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: AppIcon(
                                        obscure
                                            ? AppIcons.eyeOpen
                                            : AppIcons.eyeClosed,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  onChanged: (_) =>
                                      _passwordError.value = null,
                                  onSubmitted: (_) => _onSubmit(vm),
                                ),
                              ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          key: const Key('login_submit_button'),
                          label: 'Войти',
                          isLoading: isSubmitting,
                          onPressed: isSubmitting ? null : () => _onSubmit(vm),
                        ),
                        const SizedBox(height: 8),
                        AppTextButton(
                          label: 'Нет аккаунта? Зарегистрироваться',
                          onPressed: isSubmitting
                              ? null
                              : () => context.go(Routes.register),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
