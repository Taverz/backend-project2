class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
}
