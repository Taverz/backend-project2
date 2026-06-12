import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('вызывает action по истечении задержки', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int calls = 0;
      debouncer(() => calls++);
      expect(calls, 0); // ещё не вызван

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(calls, 1);

      debouncer.dispose();
    });

    test('отменяет предыдущий вызов если вызван снова до задержки', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int calls = 0;
      String? lastValue;

      debouncer(() {
        calls++;
        lastValue = 'first';
      });
      await Future<void>.delayed(const Duration(milliseconds: 30));

      debouncer(() {
        calls++;
        lastValue = 'second';
      });
      await Future<void>.delayed(const Duration(milliseconds: 30));

      debouncer(() {
        calls++;
        lastValue = 'third';
      });

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Только последний вызов должен выполниться
      expect(calls, 1);
      expect(lastValue, 'third');

      debouncer.dispose();
    });

    test('dispose отменяет pending вызов', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int calls = 0;

      debouncer(() => calls++);
      debouncer.dispose(); // отменяем

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(calls, 0); // не должен был вызваться
    });

    test('множественные последовательные вызовы — только один срабатывает', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int calls = 0;

      for (int i = 0; i < 10; i++) {
        debouncer(() => calls++);
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(calls, 1);

      debouncer.dispose();
    });

    test('можно вызвать снова после отработки', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int calls = 0;

      debouncer(() => calls++);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(calls, 1);

      debouncer(() => calls++);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(calls, 2);

      debouncer.dispose();
    });
  });
}
