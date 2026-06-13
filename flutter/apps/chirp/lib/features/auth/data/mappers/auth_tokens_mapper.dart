import 'package:app_api/app_api.dart';

import '../../domain/entities/auth_tokens.dart';

abstract final class AuthTokensMapper {
  static AuthTokens fromDto(AuthResponseDto dto) =>
      AuthTokens(access: dto.accessToken, refresh: dto.refreshToken);
}
