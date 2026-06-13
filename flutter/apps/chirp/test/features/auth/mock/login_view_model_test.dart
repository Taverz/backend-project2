import 'package:chirp/core/error/failures.dart';
import 'package:chirp/features/auth/domain/usecases/login_usecase.dart';
import 'package:chirp/features/auth/presentation/bloc/login_bloc.dart';
import 'package:chirp/features/auth/presentation/view_models/login_view_model.dart';
import 'package:chirp/features/auth/presentation/view_models/login_view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late _MockLoginUseCase useCase;
  late LoginBloc bloc;
  late BlocLoginViewModel vm;

  setUp(() {
    useCase = _MockLoginUseCase();
    bloc = LoginBloc(useCase);
    vm = BlocLoginViewModel(bloc);
  });

  tearDown(() {
    vm.dispose();
    bloc.close();
  });

  group('BlocLoginViewModel', () {
    test('начальный state — initial', () {
      expect(vm.state.value, LoginViewState.initial);
    });

    test('happy path: submit → isSubmitting=true → isSuccess=true', () async {
      when(
        () => useCase(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      final transitions = <LoginViewState>[];
      vm.state.addListener(() => transitions.add(vm.state.value));

      await vm.submit(email: 'user@example.com', password: 'pass1234');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transitions.map((s) => s.isSubmitting), contains(true));
      expect(transitions.last.isSuccess, true);
      expect(transitions.last.isSubmitting, false);
    });

    test('failure: usecase бросает Failure → state.failure != null', () async {
      when(
        () => useCase(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ValidationFailure('boom'));

      final transitions = <LoginViewState>[];
      vm.state.addListener(() => transitions.add(vm.state.value));

      await vm.submit(email: 'user@example.com', password: 'pass1234');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transitions.last.isSubmitting, false);
      expect(transitions.last.failure, isA<ValidationFailure>());
    });
  });
}
