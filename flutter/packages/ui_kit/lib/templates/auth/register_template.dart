import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

import '../../atoms/app_button.dart';
import '../../atoms/app_icon.dart';
import '../../atoms/app_text_field.dart';
import '../../icons/app_icon_data.dart';
import '../../molecules/app_app_bar.dart';
import '../../theme/app_colors.dart';

/// **Template** (Atomic Design): чистый UI экрана регистрации. См. doc к
/// `LoginTemplate` — те же принципы (только props, никакой logic).
class RegisterTemplate extends StatelessWidget {
  const RegisterTemplate({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onLoginTap,
    required this.onTogglePassword,
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.title = 'Регистрация',
    this.submitLabel = 'Создать аккаунт',
    this.goToLoginLabel = 'Уже есть аккаунт? Войти',
  });

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;
  final VoidCallback onTogglePassword;
  final String title;
  final String submitLabel;
  final String goToLoginLabel;

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
                      key: const Key('register_username_field'),
                      controller: usernameController,
                      label: 'Имя пользователя',
                      errorText: usernameError,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('register_email_field'),
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
                      key: const Key('register_password_field'),
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
                      key: const Key('register_submit_button'),
                      label: submitLabel,
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : onSubmit,
                    ),
                    const SizedBox(height: 8),
                    AppTextButton(
                      label: goToLoginLabel,
                      onPressed: isSubmitting ? null : onLoginTap,
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
