import 'package:app_api/app_api.dart';
import 'package:chirp/core/error/exceptions.dart';
import 'package:chirp/core/error/failures.dart';
import 'package:chirp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements AuthRemoteDataSource {}

class _FakeLoginDto extends Fake implements LoginRequestDto {}

class _FakeRegisterDto extends Fake implements RegisterRequestDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLoginDto());
    registerFallbackValue(_FakeRegisterDto());
  });

  late _MockDataSource ds;
  late AuthRepositoryImpl repo;

  setUp(() {
    ds = _MockDataSource();
    repo = AuthRepositoryImpl(ds);
  });

  const dto = AuthResponseDto(accessToken: 'a', refreshToken: 'r');

  group('login', () {
    test('возвращает AuthTokens при успехе', () async {
      when(() => ds.login(any())).thenAnswer((_) async => dto);

      final tokens = await repo.login(email: 'e@e.com', password: 'pass1234');

      expect(tokens.access, 'a');
      expect(tokens.refresh, 'r');
    });

    test(
      'бросает ValidationFailure при UnauthorizedException (неверные креды)',
      () {
        when(() => ds.login(any())).thenThrow(const UnauthorizedException());

        expect(
          () => repo.login(email: 'e@e.com', password: 'pass1234'),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('бросает NetworkFailure при NetworkException', () {
      when(() => ds.login(any())).thenThrow(const NetworkException());

      expect(
        () => repo.login(email: 'e@e.com', password: 'pass1234'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('бросает ServerFailure при ApiException(500)', () {
      when(() => ds.login(any())).thenThrow(
        const ApiException(statusCode: 500, message: 'boom'),
      );

      expect(
        () => repo.login(email: 'e@e.com', password: 'pass1234'),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('register', () {
    test('возвращает AuthTokens при успехе', () async {
      when(() => ds.register(any())).thenAnswer((_) async => dto);

      final tokens = await repo.register(
        username: 'nikita',
        email: 'e@e.com',
        password: 'pass1234',
      );

      expect(tokens.access, 'a');
    });

    test(
      'бросает ValidationFailure при ApiException(409) — email taken',
      () {
        when(() => ds.register(any())).thenThrow(
          const ApiException(
            statusCode: 409,
            message: 'email already registered',
          ),
        );

        expect(
          () => repo.register(
            username: 'nikita',
            email: 'taken@e.com',
            password: 'pass1234',
          ),
          throwsA(
            isA<ValidationFailure>().having(
              (f) => f.message,
              'message',
              contains('email'),
            ),
          ),
        );
      },
    );

    test('бросает ValidationFailure при ApiException(400)', () {
      when(() => ds.register(any())).thenThrow(
        const ApiException(statusCode: 400, message: 'username too short'),
      );

      expect(
        () => repo.register(
          username: 'x',
          email: 'e@e.com',
          password: 'pass1234',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('бросает NetworkFailure при NetworkException', () {
      when(() => ds.register(any())).thenThrow(const NetworkException());

      expect(
        () => repo.register(
          username: 'nikita',
          email: 'e@e.com',
          password: 'pass1234',
        ),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
