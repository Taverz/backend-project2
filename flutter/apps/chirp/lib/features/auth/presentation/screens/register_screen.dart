import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/services.dart' show TextInputAction;
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppAppBar(title: 'Регистрация'),
            Expanded(
              child: ValueListenableBuilder<RegisterViewState>(
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
                          valueListenable: _usernameError,
                          builder: (_, error, __) => AppTextField(
                            key: const Key('register_username_field'),
                            controller: _usernameController,
                            label: 'Имя пользователя',
                            errorText: error,
                            enabled: !isSubmitting,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            onChanged: (_) => _usernameError.value = null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<String?>(
                          valueListenable: _emailError,
                          builder: (_, error, __) => AppTextField(
                            key: const Key('register_email_field'),
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
                                  key: const Key('register_password_field'),
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
                          key: const Key('register_submit_button'),
                          label: 'Создать аккаунт',
                          isLoading: isSubmitting,
                          onPressed: isSubmitting ? null : () => _onSubmit(vm),
                        ),
                        const SizedBox(height: 8),
                        AppTextButton(
                          label: 'Уже есть аккаунт? Войти',
                          onPressed: isSubmitting
                              ? null
                              : () => context.go(Routes.login),
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
