import 'package:app_api/app_api.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/auth_tokens_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _dataSource.login(
        LoginRequestDto(email: email, password: password),
      );
      return AuthTokensMapper.fromDto(dto);
    } on UnauthorizedException {
      throw const ValidationFailure('Неверный email или пароль');
    } on ApiException catch (e) {
      throw _mapApi(e);
    } on NetworkException {
      throw const NetworkFailure();
    }
  }

  @override
  Future<AuthTokens> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _dataSource.register(
        RegisterRequestDto(
          username: username,
          email: email,
          password: password,
        ),
      );
      return AuthTokensMapper.fromDto(dto);
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on ApiException catch (e) {
      throw _mapApi(e);
    } on NetworkException {
      throw const NetworkFailure();
    }
  }

  Failure _mapApi(ApiException e) {
    if (e.statusCode == 400 || e.statusCode == 409) {
      return ValidationFailure(e.message);
    }
    if (e.statusCode == 404) return const NotFoundFailure();
    return ServerFailure(statusCode: e.statusCode);
  }
}
