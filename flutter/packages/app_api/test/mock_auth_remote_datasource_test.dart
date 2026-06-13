import 'package:app_api/app_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockAuthRemoteDataSource', () {
    const ds = MockAuthRemoteDataSource(latency: Duration.zero);

    test('login возвращает DTO из фикстуры', () async {
      final dto = await ds.login(
        const LoginRequestDto(email: 'a@b.com', password: 'x'),
      );

      expect(dto.accessToken.isNotEmpty, isTrue);
      expect(dto.refreshToken.isNotEmpty, isTrue);
      expect(dto.accessToken, contains('mock-access-token'));
    });

    test('register возвращает DTO из фикстуры', () async {
      final dto = await ds.register(
        const RegisterRequestDto(
          username: 'nikita',
          email: 'a@b.com',
          password: 'x',
        ),
      );

      expect(dto.accessToken, contains('mock-access-token-new'));
      expect(dto.refreshToken, contains('mock-refresh-token-new'));
    });
  });

  group('FixtureLoader', () {
    test('loadJson возвращает декодированный объект', () async {
      final json = await FixtureLoader.loadJson(
        'auth/login_request.json',
      );

      expect(json['email'], 'nikita@chirp.app');
      expect(json['password'], isNotEmpty);
    });
  });
}
