import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

/// Use-cases для **Templates** (Atomic Design) — экраны без state-manager.
/// Templates принимают только props (controllers + callbacks), поэтому
/// видны прямо в storybook без AuthScope / Bloc / ViewModel.

// ── Login ────────────────────────────────────────────────────────────────────

final loginTemplateUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(name: 'Empty', builder: (_) => const _LoginHarness()),
  WidgetbookUseCase(
    name: 'Filled',
    builder: (_) => const _LoginHarness(
      initialEmail: 'nikita@chirp.app',
      initialPassword: 'qwerty12345',
    ),
  ),
  WidgetbookUseCase(
    name: 'With validation errors',
    builder: (_) => const _LoginHarness(
      initialEmail: 'not-email',
      initialPassword: 'x',
      emailError: 'Неверный формат email',
      passwordError: 'Минимум 8 символов',
    ),
  ),
  WidgetbookUseCase(
    name: 'Submitting (loading)',
    builder: (_) => const _LoginHarness(
      initialEmail: 'nikita@chirp.app',
      initialPassword: 'qwerty12345',
      isSubmitting: true,
    ),
  ),
];

class _LoginHarness extends StatefulWidget {
  const _LoginHarness({
    this.initialEmail = '',
    this.initialPassword = '',
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
  });

  final String initialEmail;
  final String initialPassword;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;

  @override
  State<_LoginHarness> createState() => _LoginHarnessState();
}

class _LoginHarnessState extends State<_LoginHarness> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail);
    _password = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginTemplate(
      emailController: _email,
      passwordController: _password,
      emailError: widget.emailError,
      passwordError: widget.passwordError,
      obscurePassword: _obscure,
      isSubmitting: widget.isSubmitting,
      onSubmit: () {},
      onRegisterTap: () {},
      onTogglePassword: () => setState(() => _obscure = !_obscure),
    );
  }
}

// ── Register ─────────────────────────────────────────────────────────────────

final registerTemplateUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(name: 'Empty', builder: (_) => const _RegisterHarness()),
  WidgetbookUseCase(
    name: 'Filled',
    builder: (_) => const _RegisterHarness(
      initialUsername: 'nikita',
      initialEmail: 'nikita@chirp.app',
      initialPassword: 'qwerty12345',
    ),
  ),
  WidgetbookUseCase(
    name: 'With validation errors',
    builder: (_) => const _RegisterHarness(
      initialUsername: 'ab',
      initialEmail: 'not-email',
      initialPassword: 'x',
      usernameError: 'Минимум 3 символа',
      emailError: 'Неверный формат email',
      passwordError: 'Минимум 8 символов',
    ),
  ),
  WidgetbookUseCase(
    name: 'Submitting (loading)',
    builder: (_) => const _RegisterHarness(
      initialUsername: 'nikita',
      initialEmail: 'nikita@chirp.app',
      initialPassword: 'qwerty12345',
      isSubmitting: true,
    ),
  ),
];

class _RegisterHarness extends StatefulWidget {
  const _RegisterHarness({
    this.initialUsername = '',
    this.initialEmail = '',
    this.initialPassword = '',
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
  });

  final String initialUsername;
  final String initialEmail;
  final String initialPassword;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;

  @override
  State<_RegisterHarness> createState() => _RegisterHarnessState();
}

class _RegisterHarnessState extends State<_RegisterHarness> {
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.initialUsername);
    _email = TextEditingController(text: widget.initialEmail);
    _password = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterTemplate(
      usernameController: _username,
      emailController: _email,
      passwordController: _password,
      usernameError: widget.usernameError,
      emailError: widget.emailError,
      passwordError: widget.passwordError,
      obscurePassword: _obscure,
      isSubmitting: widget.isSubmitting,
      onSubmit: () {},
      onLoginTap: () {},
      onTogglePassword: () => setState(() => _obscure = !_obscure),
    );
  }
}
