import 'package:chirp/core/error/failures.dart';
import 'package:chirp/core/session/session_controller.dart';
import 'package:chirp/features/auth/domain/entities/auth_tokens.dart';
import 'package:chirp/features/auth/domain/repositories/auth_repository.dart';
import 'package:chirp/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionController extends Mock implements SessionController {}

void main() {
  late _MockAuthRepository repo;
  late _MockSessionController session;
  late RegisterUseCase useCase;

  setUp(() {
    repo = _MockAuthRepository();
    session = _MockSessionController();
    useCase = RegisterUseCase(repo, session);
  });

  group('RegisterUseCase', () {
    test('happy path: repo.register → session.update', () async {
      const tokens = AuthTokens(access: 'a-new', refresh: 'r-new');
      when(
        () => repo.register(
          username: any(named: 'username'),
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

      await useCase(
        username: 'nikita',
        email: 'user@example.com',
        password: 'pass1234',
      );

      verify(
        () => repo.register(
          username: 'nikita',
          email: 'user@example.com',
          password: 'pass1234',
        ),
      ).called(1);
      verify(
        () => session.update(accessToken: 'a-new', refreshToken: 'r-new'),
      ).called(1);
    });

    test('repo бросает Failure (email taken) → пробрасывается', () async {
      when(
        () => repo.register(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ValidationFailure('email already registered'));

      await expectLater(
        useCase(
          username: 'nikita',
          email: 'taken@example.com',
          password: 'pass1234',
        ),
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
