import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет соединения с сетью']);
}

final class ServerFailure extends Failure {
  const ServerFailure({
    required this.statusCode,
    String message = 'Ошибка сервера',
  }) : super(message);
  final int statusCode;

  @override
  List<Object?> get props => [statusCode, message];
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Сессия истекла']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Не найдено']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Неизвестная ошибка']);
}
