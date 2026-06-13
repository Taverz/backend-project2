import 'package:app_api/app_api.dart';
import 'package:chirp/features/auth/data/mappers/auth_tokens_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // `rootBundle` доступен в тестах только после initBinding'а.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthTokensMapper', () {
    test('login_response.json: DTO → AuthTokens с access/refresh', () async {
      final json = await FixtureLoader.loadJson(
        'auth/login_response.json',
      );
      final dto = AuthResponseDto.fromJson(json);

      final entity = AuthTokensMapper.fromDto(dto);

      expect(entity.access, dto.accessToken);
      expect(entity.refresh, dto.refreshToken);
      expect(entity.access.isNotEmpty, isTrue);
      expect(entity.refresh.isNotEmpty, isTrue);
    });

    test('register_response.json: DTO → AuthTokens', () async {
      final json = await FixtureLoader.loadJson(
        'auth/register_response.json',
      );
      final dto = AuthResponseDto.fromJson(json);

      final entity = AuthTokensMapper.fromDto(dto);

      expect(entity.access, dto.accessToken);
      expect(entity.refresh, dto.refreshToken);
    });

    test('equatable: одинаковые токены равны', () async {
      final json = await FixtureLoader.loadJson(
        'auth/login_response.json',
      );
      final dto = AuthResponseDto.fromJson(json);
      final a = AuthTokensMapper.fromDto(dto);
      final b = AuthTokensMapper.fromDto(dto);
      expect(a, equals(b));
    });
  });
}
