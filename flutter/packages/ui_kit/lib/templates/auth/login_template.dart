import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

import '../../atoms/app_button.dart';
import '../../atoms/app_icon.dart';
import '../../atoms/app_text_field.dart';
import '../../icons/app_icon_data.dart';
import '../../molecules/app_app_bar.dart';
import '../../theme/app_colors.dart';

/// **Template** (Atomic Design): чистый UI экрана логина.
/// Никакого state-manager'а, навигации, validation-логики внутри — только props.
/// Реальный экран в `apps/chirp/.../login_screen.dart` оборачивает template,
/// прокидывая controllers + callbacks из своего ViewModel.
///
/// В storybook используется напрямую с фейковыми props для визуальной проверки.
class LoginTemplate extends StatelessWidget {
  const LoginTemplate({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onRegisterTap,
    required this.onTogglePassword,
    this.emailError,
    this.passwordError,
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.title = 'Вход',
    this.submitLabel = 'Войти',
    this.goToRegisterLabel = 'Нет аккаунта? Зарегистрироваться',
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onRegisterTap;
  final VoidCallback onTogglePassword;
  final String title;
  final String submitLabel;
  final String goToRegisterLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppAppBar(title: title),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('login_email_field'),
                      controller: emailController,
                      label: 'Email',
                      errorText: emailError,
                      enabled: !isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('login_password_field'),
                      controller: passwordController,
                      label: 'Пароль',
                      errorText: passwordError,
                      enabled: !isSubmitting,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      onSubmitted: (_) => onSubmit(),
                      suffix: GestureDetector(
                        onTap: onTogglePassword,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AppIcon(
                            obscurePassword
                                ? AppIcons.eyeOpen
                                : AppIcons.eyeClosed,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      key: const Key('login_submit_button'),
                      label: submitLabel,
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : onSubmit,
                    ),
                    const SizedBox(height: 8),
                    AppTextButton(
                      label: goToRegisterLabel,
                      onPressed: isSubmitting ? null : onRegisterTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
