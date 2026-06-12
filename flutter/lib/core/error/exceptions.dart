class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}
