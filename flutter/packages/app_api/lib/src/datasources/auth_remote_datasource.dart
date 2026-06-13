import 'package:dio/dio.dart';

import '../dto/auth_response_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';

/// Источник сетевых данных для `/api/v1/auth/*`.
/// Соответствует swagger-контракту бэкенда (`backend/docs/swagger.json`).
/// Какая именно платформа реализует контракт на сервере (Go, Python и т.п.)
/// — приложению неважно.
///
/// Используется через `AppApiClient.auth` — фичи не оборачивают этот
/// datasource ещё одним слоем, репозитории фичи зовут его напрямую.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseDto> login(LoginRequestDto request);
  Future<AuthResponseDto> register(RegisterRequestDto request);
}

class AuthRemoteDataSourceDioImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceDioImpl(this._dio);

  final Dio _dio;

  static const _loginPath = '/api/v1/auth/login';
  static const _registerPath = '/api/v1/auth/register';

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _loginPath,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data!);
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _registerPath,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data!);
  }
}
