import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';

/// Подмешивается в State экрана. Даёт методы для валидации полей формы
/// без отдельного Cubit/Bloc — это локальная UI-логика.
mixin AuthFormValidationMixin<W extends StatefulWidget> on State<W> {
  /// Возвращает true, если все поля валидны. Иначе обновляет переданные
  /// notifier'ы текстами ошибок.
  bool validateLoginForm({
    required String email,
    required String password,
    required ValueNotifier<String?> emailError,
    required ValueNotifier<String?> passwordError,
  }) {
    final emailMsg = Validators.email(email);
    final passwordMsg = Validators.password(password);
    emailError.value = emailMsg;
    passwordError.value = passwordMsg;
    return emailMsg == null && passwordMsg == null;
  }

  bool validateRegisterForm({
    required String username,
    required String email,
    required String password,
    required ValueNotifier<String?> usernameError,
    required ValueNotifier<String?> emailError,
    required ValueNotifier<String?> passwordError,
  }) {
    final usernameMsg = Validators.username(username);
    final emailMsg = Validators.email(email);
    final passwordMsg = Validators.password(password);
    usernameError.value = usernameMsg;
    emailError.value = emailMsg;
    passwordError.value = passwordMsg;
    return usernameMsg == null && emailMsg == null && passwordMsg == null;
  }
}
