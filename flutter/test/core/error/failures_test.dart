import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/error/failures.dart';

void main() {
  group('NetworkFailure', () {
    test('два экземпляра равны (equatable)', () {
      expect(const NetworkFailure(), const NetworkFailure());
    });

    test('дефолтное сообщение', () {
      expect(const NetworkFailure().message, isNotEmpty);
    });

    test('кастомное сообщение', () {
      expect(const NetworkFailure('timeout').message, 'timeout');
    });
  });

  group('ServerFailure', () {
    test('равны при одинаковом statusCode и message', () {
      expect(
        const ServerFailure(statusCode: 500),
        const ServerFailure(statusCode: 500),
      );
    });

    test('не равны при разных кодах', () {
      expect(
        const ServerFailure(statusCode: 404),
        isNot(const ServerFailure(statusCode: 500)),
      );
    });

    test('хранит statusCode', () {
      expect(const ServerFailure(statusCode: 503).statusCode, 503);
    });
  });

  group('ValidationFailure', () {
    test('равны при одном message', () {
      expect(
        const ValidationFailure('неверный email'),
        const ValidationFailure('неверный email'),
      );
    });

    test('не равны при разных message', () {
      expect(
        const ValidationFailure('ошибка A'),
        isNot(const ValidationFailure('ошибка B')),
      );
    });
  });

  group('sealed hierarchy', () {
    test('NetworkFailure is Failure', () {
      expect(const NetworkFailure(), isA<Failure>());
    });

    test('ServerFailure is Failure', () {
      expect(const ServerFailure(statusCode: 500), isA<Failure>());
    });

    test('UnauthorizedFailure is Failure', () {
      expect(const UnauthorizedFailure(), isA<Failure>());
    });

    test('ValidationFailure is Failure', () {
      expect(const ValidationFailure('x'), isA<Failure>());
    });

    test('NotFoundFailure is Failure', () {
      expect(const NotFoundFailure(), isA<Failure>());
    });

    test('UnknownFailure is Failure', () {
      expect(const UnknownFailure(), isA<Failure>());
    });

    test('switch exhaustive — все ветки реализованы', () {
      // Если добавить новый подкласс Failure и забыть ветку — compile error здесь.
      const Failure f = NetworkFailure();
      final label = switch (f) {
        NetworkFailure() => 'network',
        ServerFailure() => 'server',
        UnauthorizedFailure() => 'unauthorized',
        ValidationFailure() => 'validation',
        NotFoundFailure() => 'notFound',
        UnknownFailure() => 'unknown',
      };
      expect(label, 'network');
    });
  });
}
