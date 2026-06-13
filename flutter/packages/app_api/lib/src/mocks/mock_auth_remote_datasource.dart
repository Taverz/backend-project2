import '../datasources/auth_remote_datasource.dart';
import '../dto/auth_response_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';
import '../fixtures/fixture_loader.dart';

/// Mock-реализация `AuthRemoteDataSource`: возвращает заранее заготовленные
/// JSON из `fixtures/auth/*.json`. Mock-first — приложение работает без
/// реального бэкенда (`--dart-define=USE_MOCK_API=true`).
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  const MockAuthRemoteDataSource({
    this.latency = const Duration(milliseconds: 200),
  });

  /// Имитация сетевой задержки, чтобы UI-состояния `isSubmitting`
  /// были видны в оффлайн-режиме.
  final Duration latency;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(latency);
    final json = await FixtureLoader.loadJson('auth/login_response.json');
    return AuthResponseDto.fromJson(json);
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    await Future<void>.delayed(latency);
    final json = await FixtureLoader.loadJson('auth/register_response.json');
    return AuthResponseDto.fromJson(json);
  }
}
