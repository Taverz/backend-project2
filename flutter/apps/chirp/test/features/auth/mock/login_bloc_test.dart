import 'package:bloc_test/bloc_test.dart';
import 'package:chirp/core/error/failures.dart';
import 'package:chirp/features/auth/domain/usecases/login_usecase.dart';
import 'package:chirp/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late _MockLoginUseCase useCase;

  setUp(() {
    useCase = _MockLoginUseCase();
  });

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'happy path: Initial → InProgress → Success',
      build: () {
        when(
          () => useCase(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
        return LoginBloc(useCase);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(email: 'user@example.com', password: 'pass1234'),
      ),
      expect: () => [
        isA<LoginInProgress>(),
        isA<LoginSuccess>(),
      ],
      verify: (_) {
        verify(
          () => useCase(email: 'user@example.com', password: 'pass1234'),
        ).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'usecase бросает Failure → InProgress → FailureState с этим Failure',
      build: () {
        when(
          () => useCase(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const ValidationFailure('Неверный email или пароль'));
        return LoginBloc(useCase);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(email: 'user@example.com', password: 'pass1234'),
      ),
      expect: () => [
        isA<LoginInProgress>(),
        isA<LoginFailureState>().having(
          (s) => s.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'неизвестное исключение оборачивается в UnknownFailure',
      build: () {
        when(
          () => useCase(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(StateError('boom'));
        return LoginBloc(useCase);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(email: 'user@example.com', password: 'pass1234'),
      ),
      expect: () => [
        isA<LoginInProgress>(),
        isA<LoginFailureState>().having(
          (s) => s.failure,
          'failure',
          isA<UnknownFailure>(),
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'второй submit во время InProgress игнорируется',
      build: () {
        when(
          () => useCase(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
        });
        return LoginBloc(useCase);
      },
      act: (bloc) async {
        bloc.add(
          const LoginSubmitted(
            email: 'user@example.com',
            password: 'pass1234',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(
          const LoginSubmitted(
            email: 'user@example.com',
            password: 'pass1234',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      verify: (_) {
        verify(
          () => useCase(email: 'user@example.com', password: 'pass1234'),
        ).called(1);
      },
    );
  });
}
