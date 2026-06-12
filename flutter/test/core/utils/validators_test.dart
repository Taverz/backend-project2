import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('возвращает null для валидного email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('user.name+tag@sub.domain.org'), isNull);
    });

    test('ошибка при пустой строке', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('ошибка без @', () {
      expect(Validators.email('userexample.com'), isNotNull);
    });

    test('ошибка без домена', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('ошибка без TLD', () {
      expect(Validators.email('user@example'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('возвращает null для ≥8 символов', () {
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password('longpassword123'), isNull);
    });

    test('ошибка для < 8 символов', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });

    test('граничное значение: ровно 8 символов валидно', () {
      expect(Validators.password('abcdefgh'), isNull);
    });

    test('граничное значение: 7 символов невалидно', () {
      expect(Validators.password('abcdefg'), isNotNull);
    });
  });

  group('Validators.username', () {
    test('возвращает null для валидного имени', () {
      expect(Validators.username('john'), isNull);
      expect(Validators.username('john_doe'), isNull);
    });

    test('ошибка при пустой строке', () {
      expect(Validators.username(''), isNotNull);
      expect(Validators.username(null), isNotNull);
    });

    test('ошибка для < 3 символов', () {
      expect(Validators.username('ab'), isNotNull);
    });

    test('ошибка для > 50 символов', () {
      expect(Validators.username('a' * 51), isNotNull);
    });

    test('граничные значения: 3 и 50 символов — валидно', () {
      expect(Validators.username('abc'), isNull);
      expect(Validators.username('a' * 50), isNull);
    });
  });
}
