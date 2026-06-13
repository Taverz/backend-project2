import 'package:chirp/features/auth/presentation/scope/auth_scope.dart';
import 'package:chirp/features/auth/presentation/screens/login_screen.dart';
import 'package:chirp/features/auth/presentation/view_models/login_view_model.dart';
import 'package:chirp/features/auth/presentation/view_models/login_view_state.dart';
import 'package:chirp/features/auth/presentation/view_models/register_view_model.dart';
import 'package:chirp/features/auth/presentation/view_models/register_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ui_kit/ui_kit.dart';

class _MockLoginVm extends Mock implements LoginViewModel {}

class _MockRegisterVm extends Mock implements RegisterViewModel {}

Widget _harness({
  required LoginViewModel loginVm,
  required RegisterViewModel registerVm,
}) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => AuthScope(
          loginViewModel: loginVm,
          registerViewModel: registerVm,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  late _MockLoginVm loginVm;
  late _MockRegisterVm registerVm;
  late ValueNotifier<LoginViewState> loginNotifier;
  late ValueNotifier<RegisterViewState> registerNotifier;

  setUp(() {
    loginVm = _MockLoginVm();
    registerVm = _MockRegisterVm();
    loginNotifier = ValueNotifier<LoginViewState>(LoginViewState.initial);
    registerNotifier = ValueNotifier<RegisterViewState>(
      RegisterViewState.initial,
    );
    when(() => loginVm.state).thenReturn(loginNotifier);
    when(() => registerVm.state).thenReturn(registerNotifier);
    when(
      () => loginVm.submit(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    loginNotifier.dispose();
    registerNotifier.dispose();
  });

  group('LoginScreen', () {
    testWidgets('рендерит email, password и кнопку submit', (tester) async {
      await tester.pumpWidget(
        _harness(loginVm: loginVm, registerVm: registerVm),
      );

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    });

    testWidgets('пустые поля → tap submit → VM.submit НЕ вызван',
        (tester) async {
      await tester.pumpWidget(
        _harness(loginVm: loginVm, registerVm: registerVm),
      );

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      verifyNever(
        () => loginVm.submit(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets(
      'невалидный email → submit не зовёт VM, errorText появляется',
      (tester) async {
        await tester.pumpWidget(
          _harness(loginVm: loginVm, registerVm: registerVm),
        );

        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'not-an-email',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'pass1234',
        );
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pump();

        verifyNever(
          () => loginVm.submit(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
        expect(find.text('Неверный формат email'), findsOneWidget);
      },
    );

    testWidgets(
      'валидные данные → VM.submit с trim()-нутым email',
      (tester) async {
        await tester.pumpWidget(
          _harness(loginVm: loginVm, registerVm: registerVm),
        );

        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          '  user@example.com  ',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'pass1234',
        );
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pump();

        verify(
          () => loginVm.submit(
            email: 'user@example.com',
            password: 'pass1234',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'isSubmitting=true → кнопка disabled (onPressed=null), '
      'AppLoader виден',
      (tester) async {
        await tester.pumpWidget(
          _harness(loginVm: loginVm, registerVm: registerVm),
        );

        loginNotifier.value = const LoginViewState(isSubmitting: true);
        await tester.pump();

        final button = tester.widget<AppButton>(
          find.byKey(const Key('login_submit_button')),
        );
        expect(button.onPressed, isNull);
        expect(button.isLoading, isTrue);
      },
    );
  });
}
