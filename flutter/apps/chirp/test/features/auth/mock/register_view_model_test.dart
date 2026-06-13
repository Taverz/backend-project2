import 'package:chirp/core/error/failures.dart';
import 'package:chirp/features/auth/domain/usecases/register_usecase.dart';
import 'package:chirp/features/auth/presentation/bloc/register_bloc.dart';
import 'package:chirp/features/auth/presentation/view_models/register_view_model.dart';
import 'package:chirp/features/auth/presentation/view_models/register_view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late _MockRegisterUseCase useCase;
  late RegisterBloc bloc;
  late BlocRegisterViewModel vm;

  setUp(() {
    useCase = _MockRegisterUseCase();
    bloc = RegisterBloc(useCase);
    vm = BlocRegisterViewModel(bloc);
  });

  tearDown(() {
    vm.dispose();
    bloc.close();
  });

  group('BlocRegisterViewModel', () {
    test('начальный state — initial', () {
      expect(vm.state.value, RegisterViewState.initial);
    });

    test('happy path: submit → isSubmitting=true → isSuccess=true', () async {
      when(
        () => useCase(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      final transitions = <RegisterViewState>[];
      vm.state.addListener(() => transitions.add(vm.state.value));

      await vm.submit(
        username: 'nikita',
        email: 'user@example.com',
        password: 'pass1234',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transitions.map((s) => s.isSubmitting), contains(true));
      expect(transitions.last.isSuccess, true);
      expect(transitions.last.isSubmitting, false);
    });

    test(
      'failure (email taken) → state.failure = ValidationFailure',
      () async {
        when(
          () => useCase(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const ValidationFailure('email already registered'));

        final transitions = <RegisterViewState>[];
        vm.state.addListener(() => transitions.add(vm.state.value));

        await vm.submit(
          username: 'nikita',
          email: 'taken@example.com',
          password: 'pass1234',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(transitions.last.isSubmitting, false);
        expect(transitions.last.failure, isA<ValidationFailure>());
      },
    );
  });
}
