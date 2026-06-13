// Widget-integration test: проходит весь путь login через РЕАЛЬНЫЕ слои
// (Repository → UseCase → ViewModel → UI → Session). Сетевой слой — локальный
// `_FakeAuthRemoteDataSource` с жёстко заданным ответом. Mock-clients из
// app_api (с фикстурами) тестируются отдельно в `packages/app_api/test/`;
// здесь — проверка склейки фичи целиком.
//
// Запускается обычным `flutter test`, без устройства.
import 'package:app_api/app_api.dart';
import 'package:chirp/core/session/session_controller.dart';
import 'package:chirp/core/session/session_state.dart';
import 'package:chirp/core/session/token_storage.dart';
import 'package:chirp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chirp/features/auth/domain/usecases/login_usecase.dart';
import 'package:chirp/features/auth/domain/usecases/register_usecase.dart';
import 'package:chirp/features/auth/presentation/bloc/login_bloc.dart';
import 'package:chirp/features/auth/presentation/bloc/register_bloc.dart';
import 'package:chirp/features/auth/presentation/scope/auth_scope.dart';
import 'package:chirp/features/auth/presentation/screens/login_screen.dart';
import 'package:chirp/features/auth/presentation/screens/register_screen.dart';
import 'package:chirp/features/auth/presentation/view_models/login_view_model.dart';
import 'package:chirp/features/auth/presentation/view_models/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  int loginCalls = 0;
  int registerCalls = 0;
  // Минимальный latency (не zero) — fake-async тестер должен «прокрутить»
  // таймер, иначе `Future.delayed(0)` зависает между pump-ами.
  Duration latency = const Duration(milliseconds: 1);

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    loginCalls++;
    await Future<void>.delayed(latency);
    return const AuthResponseDto(
      accessToken: 'fake-access-login',
      refreshToken: 'fake-refresh-login',
    );
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    registerCalls++;
    await Future<void>.delayed(latency);
    return const AuthResponseDto(
      accessToken: 'fake-access-register',
      refreshToken: 'fake-refresh-register',
    );
  }
}

void main() {
  late _MockTokenStorage storage;
  late SessionController session;
  late _FakeAuthRemoteDataSource fakeDs;
  late AuthRepositoryImpl repo;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LoginBloc loginBloc;
  late RegisterBloc registerBloc;
  late LoginViewModel loginVm;
  late RegisterViewModel registerVm;

  setUp(() {
    storage = _MockTokenStorage();
    when(() => storage.read()).thenAnswer((_) async => null);
    when(
      () => storage.write(
        access: any(named: 'access'),
        refresh: any(named: 'refresh'),
      ),
    ).thenAnswer((_) async {});

    session = SessionController(storage);
    fakeDs = _FakeAuthRemoteDataSource();
    repo = AuthRepositoryImpl(fakeDs);
    loginUseCase = LoginUseCase(repo, session);
    registerUseCase = RegisterUseCase(repo, session);
    loginBloc = LoginBloc(loginUseCase);
    registerBloc = RegisterBloc(registerUseCase);
    loginVm = BlocLoginViewModel(loginBloc);
    registerVm = BlocRegisterViewModel(registerBloc);
  });

  tearDown(() async {
    loginVm.dispose();
    registerVm.dispose();
    await loginBloc.close();
    await registerBloc.close();
    session.dispose();
  });

  Widget harness({String initialLocation = '/login'}) {
    final router = GoRouter(
      initialLocation: initialLocation,
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
          builder: (_, __) => AuthScope(
            loginViewModel: loginVm,
            registerViewModel: registerVm,
            child: const RegisterScreen(),
          ),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('Auth flow — login', () {
    testWidgets('до submit session.state == SessionUnknown', (tester) async {
      await tester.pumpWidget(harness());
      expect(session.state, isA<SessionUnknown>());
    });

    testWidgets(
      'успешный login: ввод → submit → SessionAuthenticated + tokens записаны',
      (tester) async {
        await tester.pumpWidget(harness());

        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'user@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'pass1234',
        );
        // runAsync временно выходит из FakeAsync, чтобы реальный event-loop
        // прокачал Bloc-event → UseCase → datasource → session.update.
        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('login_submit_button')));
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(fakeDs.loginCalls, 1, reason: 'datasource не вызван');
        expect(session.state, isA<SessionAuthenticated>());
        final auth = session.state as SessionAuthenticated;
        expect(auth.accessToken, 'fake-access-login');
        expect(auth.refreshToken, 'fake-refresh-login');

        verify(
          () => storage.write(
            access: 'fake-access-login',
            refresh: 'fake-refresh-login',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'двойной tap submit во время InProgress — datasource вызван один раз',
      (tester) async {
        fakeDs.latency = const Duration(milliseconds: 50);
        await tester.pumpWidget(harness());

        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'user@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'pass1234',
        );

        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('login_submit_button')));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await tester.tap(find.byKey(const Key('login_submit_button')));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pump();

        expect(fakeDs.loginCalls, 1);
      },
    );
  });

  group('Auth flow — register', () {
    testWidgets(
      'успешный register: ввод → submit → SessionAuthenticated',
      (tester) async {
        await tester.pumpWidget(harness(initialLocation: '/register'));

        await tester.enterText(
          find.byKey(const Key('register_username_field')),
          'nikita',
        );
        await tester.enterText(
          find.byKey(const Key('register_email_field')),
          'user@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'pass1234',
        );
        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('register_submit_button')));
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(fakeDs.registerCalls, 1, reason: 'datasource не вызван');
        expect(session.state, isA<SessionAuthenticated>());
        final auth = session.state as SessionAuthenticated;
        expect(auth.accessToken, 'fake-access-register');
      },
    );
  });
}
