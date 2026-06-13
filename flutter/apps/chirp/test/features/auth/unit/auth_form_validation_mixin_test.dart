import 'package:chirp/features/auth/presentation/mixins/auth_form_validation_mixin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _DummyWidget extends StatefulWidget {
  const _DummyWidget();

  @override
  State<_DummyWidget> createState() => _DummyWidgetState();
}

class _DummyWidgetState extends State<_DummyWidget>
    with AuthFormValidationMixin<_DummyWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  // Реальный экземпляр State для тестирования миксина.
  late _DummyWidgetState mixin;
  late ValueNotifier<String?> emailError;
  late ValueNotifier<String?> passwordError;
  late ValueNotifier<String?> usernameError;

  setUp(() {
    mixin = _DummyWidgetState();
    emailError = ValueNotifier<String?>(null);
    passwordError = ValueNotifier<String?>(null);
    usernameError = ValueNotifier<String?>(null);
  });

  tearDown(() {
    emailError.dispose();
    passwordError.dispose();
    usernameError.dispose();
  });

  group('AuthFormValidationMixin.validateLoginForm', () {
    test('валидные поля → true, ошибки сброшены', () {
      final ok = mixin.validateLoginForm(
        email: 'user@example.com',
        password: 'pass1234',
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isTrue);
      expect(emailError.value, isNull);
      expect(passwordError.value, isNull);
    });

    test('невалидный email → false, emailError установлен', () {
      final ok = mixin.validateLoginForm(
        email: 'not-an-email',
        password: 'pass1234',
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isFalse);
      expect(emailError.value, isNotNull);
      expect(passwordError.value, isNull);
    });

    test('короткий пароль → false, passwordError установлен', () {
      final ok = mixin.validateLoginForm(
        email: 'user@example.com',
        password: 'x',
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isFalse);
      expect(passwordError.value, isNotNull);
    });

    test('оба невалидны → false, оба error установлены', () {
      final ok = mixin.validateLoginForm(
        email: '',
        password: '',
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isFalse);
      expect(emailError.value, isNotNull);
      expect(passwordError.value, isNotNull);
    });
  });

  group('AuthFormValidationMixin.validateRegisterForm', () {
    test('все валидны → true', () {
      final ok = mixin.validateRegisterForm(
        username: 'nikita',
        email: 'user@example.com',
        password: 'pass1234',
        usernameError: usernameError,
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isTrue);
      expect(usernameError.value, isNull);
      expect(emailError.value, isNull);
      expect(passwordError.value, isNull);
    });

    test('пустой username → false, только usernameError', () {
      final ok = mixin.validateRegisterForm(
        username: '',
        email: 'user@example.com',
        password: 'pass1234',
        usernameError: usernameError,
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isFalse);
      expect(usernameError.value, isNotNull);
      expect(emailError.value, isNull);
      expect(passwordError.value, isNull);
    });

    test('короткий username (< 3) → false', () {
      final ok = mixin.validateRegisterForm(
        username: 'ab',
        email: 'user@example.com',
        password: 'pass1234',
        usernameError: usernameError,
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isFalse);
      expect(usernameError.value, isNotNull);
    });

    test('сброс предыдущих ошибок при валидном вызове', () {
      usernameError.value = 'старая ошибка';
      emailError.value = 'старая ошибка';
      passwordError.value = 'старая ошибка';

      final ok = mixin.validateRegisterForm(
        username: 'nikita',
        email: 'user@example.com',
        password: 'pass1234',
        usernameError: usernameError,
        emailError: emailError,
        passwordError: passwordError,
      );

      expect(ok, isTrue);
      expect(usernameError.value, isNull);
      expect(emailError.value, isNull);
      expect(passwordError.value, isNull);
    });
  });
}
