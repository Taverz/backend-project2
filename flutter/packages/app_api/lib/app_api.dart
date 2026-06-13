// Client (facade)
export 'src/client/app_api_client.dart';

// DataSources (контракт API)
export 'src/datasources/auth_remote_datasource.dart';

// DTOs
export 'src/dto/auth_response_dto.dart';
export 'src/dto/login_request_dto.dart';
export 'src/dto/register_request_dto.dart';

// Fixtures + Mocks (для оффлайн-разработки и тестов)
export 'src/fixtures/fixture_loader.dart';
export 'src/mocks/mock_app_api_client.dart';
export 'src/mocks/mock_auth_remote_datasource.dart';
