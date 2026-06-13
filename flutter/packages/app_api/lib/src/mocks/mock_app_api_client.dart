import '../client/app_api_client.dart';
import '../datasources/auth_remote_datasource.dart';
import 'mock_auth_remote_datasource.dart';

/// Mock-сборка `AppApiClient` — все datasource'ы возвращают фикстуры.
/// `AppScope` подключает её при `--dart-define=USE_MOCK_API=true`.
class MockAppApiClient implements AppApiClient {
  const MockAppApiClient({this.auth = const MockAuthRemoteDataSource()});

  @override
  final AuthRemoteDataSource auth;
}
