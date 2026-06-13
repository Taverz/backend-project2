import 'package:chirp/core/error/failures.dart';
import 'package:chirp/core/session/session_controller.dart';
import 'package:chirp/features/auth/domain/entities/auth_tokens.dart';
import 'package:chirp/features/auth/domain/repositories/auth_repository.dart';
import 'package:chirp/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionController extends Mock implements SessionController {}

void main() {
  late _MockAuthRepository repo;
  late _MockSessionController session;
  late LoginUseCase useCase;

  setUp(() {
    repo = _MockAuthRepository();
    session = _MockSessionController();
    useCase = LoginUseCase(repo, session);
  });

  group('LoginUseCase', () {
    test('happy path: repo.login → session.update с теми же токенами', () async {
      const tokens = AuthTokens(access: 'a', refresh: 'r');
      when(
        () => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tokens);
      when(
        () => session.update(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      await useCase(email: 'user@example.com', password: 'pass1234');

      verify(
        () => repo.login(email: 'user@example.com', password: 'pass1234'),
      ).called(1);
      verify(
        () => session.update(accessToken: 'a', refreshToken: 'r'),
      ).called(1);
    });

    test('repo бросает Failure → пробрасывается, session.update НЕ вызван',
        () async {
      when(
        () => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ValidationFailure('bad creds'));

      await expectLater(
        useCase(email: 'user@example.com', password: 'pass1234'),
        throwsA(isA<ValidationFailure>()),
      );

      verifyNever(
        () => session.update(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });
  });
}
