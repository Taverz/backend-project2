import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/result/result.dart';
import 'package:chirp/core/error/failures.dart';

void main() {
  group('Ok', () {
    test('хранит значение', () {
      const result = Ok<int>(42);
      expect(result.value, 42);
    });

    test('isOk == true', () {
      expect(const Ok<String>('hello').isOk, isTrue);
    });

    test('isErr == false', () {
      expect(const Ok<String>('hello').isErr, isFalse);
    });

    test('valueOrThrow возвращает значение', () {
      expect(const Ok<int>(7).valueOrThrow, 7);
    });

    test('fold вызывает onOk с правильным значением', () {
      const Result<int> r = Ok(10);
      final out = r.fold((v) => 'ok:$v', (f) => 'err');
      expect(out, 'ok:10');
    });
  });

  group('Err', () {
    const failure = NetworkFailure();

    test('хранит failure', () {
      const result = Err<int>(failure);
      expect(result.failure, failure);
    });

    test('isOk == false', () {
      expect(const Err<int>(failure).isOk, isFalse);
    });

    test('isErr == true', () {
      expect(const Err<int>(failure).isErr, isTrue);
    });

    test('valueOrThrow бросает Failure', () {
      const Result<int> r = Err(failure);
      expect(() => r.valueOrThrow, throwsA(isA<NetworkFailure>()));
    });

    test('fold вызывает onErr с правильным failure', () {
      const Result<int> r = Err(failure);
      final out = r.fold((v) => 'ok', (f) => 'err:${f.runtimeType}');
      expect(out, 'err:NetworkFailure');
    });
  });

  group('Типобезопасность', () {
    test('Result<String> с Ok<String>', () {
      const Result<String> r = Ok('dart');
      expect(r.valueOrThrow, 'dart');
    });

    test('Result<List<int>>', () {
      const Result<List<int>> r = Ok([1, 2, 3]);
      expect(r.valueOrThrow, [1, 2, 3]);
    });
  });
}
