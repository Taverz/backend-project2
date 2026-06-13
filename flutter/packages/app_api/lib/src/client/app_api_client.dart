import 'package:dio/dio.dart';

import '../datasources/auth_remote_datasource.dart';

/// Фасад API-клиента. Приложение работает с этим интерфейсом,
/// не с конкретными datasource'ами — это позволяет полностью замокать клиент
/// в тестах и переключаться на mock-сборку.
abstract interface class AppApiClient {
  AuthRemoteDataSource get auth;
}

/// Реальная сборка: каждый datasource поверх общего `Dio` с интерсепторами.
class AppApiClientImpl implements AppApiClient {
  AppApiClientImpl({required Dio dio})
    : auth = AuthRemoteDataSourceDioImpl(dio);

  @override
  final AuthRemoteDataSource auth;
}
