import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/utils/date_format.dart';

void main() {
  group('DateTime.toRelativeString', () {
    DateTime ago(Duration d) => DateTime.now().subtract(d);

    test('секунды', () {
      final result = ago(const Duration(seconds: 30)).toRelativeString();
      expect(result, endsWith('с'));
    });

    test('минуты', () {
      final result = ago(const Duration(minutes: 5)).toRelativeString();
      expect(result, endsWith('м'));
    });

    test('часы', () {
      final result = ago(const Duration(hours: 3)).toRelativeString();
      expect(result, endsWith('ч'));
    });

    test('дни', () {
      final result = ago(const Duration(days: 3)).toRelativeString();
      expect(result, endsWith('д'));
    });

    test('старше 7 дней — формат dd.mm.yy', () {
      final result = ago(const Duration(days: 10)).toRelativeString();
      // Формат: 2 цифры . 2 цифры . 2 цифры
      expect(result, matches(RegExp(r'^\d{2}\.\d{2}\.\d{2}$')));
    });

    test('граница секунды→минуты: 59с', () {
      final result = ago(const Duration(seconds: 59)).toRelativeString();
      expect(result, '59с');
    });

    test('граница секунды→минуты: 60с → 1м', () {
      final result = ago(const Duration(seconds: 60)).toRelativeString();
      expect(result, '1м');
    });

    test('граница минуты→часы: 59м', () {
      final result = ago(const Duration(minutes: 59)).toRelativeString();
      expect(result, '59м');
    });

    test('граница минуты→часы: 60м → 1ч', () {
      final result = ago(const Duration(minutes: 60)).toRelativeString();
      expect(result, '1ч');
    });

    test('граница часы→дни: 23ч', () {
      final result = ago(const Duration(hours: 23)).toRelativeString();
      expect(result, '23ч');
    });

    test('граница часы→дни: 24ч → 1д', () {
      final result = ago(const Duration(hours: 24)).toRelativeString();
      expect(result, '1д');
    });

    test('граница дни→дата: 6д', () {
      final result = ago(const Duration(days: 6)).toRelativeString();
      expect(result, '6д');
    });

    test('граница дни→дата: 7д → дата', () {
      final result = ago(const Duration(days: 7)).toRelativeString();
      expect(result, matches(RegExp(r'^\d{2}\.\d{2}\.\d{2}$')));
    });
  });
}
