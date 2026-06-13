import 'package:bloc_test/bloc_test.dart';
import 'package:chirp/core/error/failures.dart';
import 'package:chirp/features/auth/domain/usecases/register_usecase.dart';
import 'package:chirp/features/auth/presentation/bloc/register_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late _MockRegisterUseCase useCase;

  setUp(() {
    useCase = _MockRegisterUseCase();
  });

  group('RegisterBloc', () {
    blocTest<RegisterBloc, RegisterState>(
      'happy path: Initial → InProgress → Success',
      build: () {
        when(
          () => useCase(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
        return RegisterBloc(useCase);
      },
      act: (bloc) => bloc.add(
        const RegisterSubmitted(
          username: 'nikita',
          email: 'user@example.com',
          password: 'pass1234',
        ),
      ),
      expect: () => [
        isA<RegisterInProgress>(),
        isA<RegisterSuccess>(),
      ],
      verify: (_) {
        verify(
          () => useCase(
            username: 'nikita',
            email: 'user@example.com',
            password: 'pass1234',
          ),
        ).called(1);
      },
    );

    blocTest<RegisterBloc, RegisterState>(
      'usecase бросает ValidationFailure (email taken) → FailureState',
      build: () {
        when(
          () => useCase(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const ValidationFailure('email already registered'));
        return RegisterBloc(useCase);
      },
      act: (bloc) => bloc.add(
        const RegisterSubmitted(
          username: 'nikita',
          email: 'taken@example.com',
          password: 'pass1234',
        ),
      ),
      expect: () => [
        isA<RegisterInProgress>(),
        isA<RegisterFailureState>().having(
          (s) => s.failure.message,
          'message',
          contains('email'),
        ),
      ],
    );
  });
}
