import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chirp/core/session/session_controller.dart';
import 'package:chirp/core/session/session_state.dart';
import 'package:chirp/core/session/token_storage.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockTokenStorage storage;
  late SessionController controller;

  setUp(() {
    storage = MockTokenStorage();
    controller = SessionController(storage);
  });

  tearDown(() => controller.dispose());

  group('init', () {
    test('эмитит authenticated, когда токены есть в хранилище', () async {
      when(() => storage.read()).thenAnswer(
        (_) async => (access: 'acc', refresh: 'ref'),
      );

      final states = <SessionState>[];
      controller.stream.listen(states.add);

      await controller.init();

      expect(controller.state, isA<SessionAuthenticated>());
      expect((controller.state as SessionAuthenticated).accessToken, 'acc');
    });

    test('эмитит unauthenticated, когда токенов нет', () async {
      when(() => storage.read()).thenAnswer((_) async => null);

      await controller.init();

      expect(controller.state, isA<SessionUnauthenticated>());
    });
  });

  group('update', () {
    test('сохраняет токены и переходит в authenticated', () async {
      when(() => storage.write(access: any(named: 'access'), refresh: any(named: 'refresh')))
          .thenAnswer((_) async {});

      await controller.update(accessToken: 'new_acc', refreshToken: 'new_ref');

      verify(() => storage.write(access: 'new_acc', refresh: 'new_ref')).called(1);
      expect(controller.state, isA<SessionAuthenticated>());
      expect((controller.state as SessionAuthenticated).accessToken, 'new_acc');
    });
  });

  group('drop', () {
    test('очищает хранилище и переходит в unauthenticated', () async {
      when(() => storage.clear()).thenAnswer((_) async {});

      await controller.drop();

      verify(() => storage.clear()).called(1);
      expect(controller.state, isA<SessionUnauthenticated>());
    });
  });

  group('listenable', () {
    test('notifier обновляется синхронно при смене состояния', () async {
      when(() => storage.write(access: any(named: 'access'), refresh: any(named: 'refresh')))
          .thenAnswer((_) async {});

      final states = <SessionState>[];
      controller.listenable.addListener(() => states.add(controller.state));

      await controller.update(accessToken: 'a', refreshToken: 'r');

      expect(states.length, 1);
      expect(states.first, isA<SessionAuthenticated>());
    });
  });

  group('stream', () {
    test('рассылает все переходы состояния подписчикам', () async {
      when(() => storage.read()).thenAnswer((_) async => null);
      when(() => storage.write(access: any(named: 'access'), refresh: any(named: 'refresh')))
          .thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});

      // Подписываемся ДО действий и ждём ровно 3 события.
      final eventsFuture = controller.stream.take(3).toList();

      await controller.init();       // → unauthenticated
      await controller.update(accessToken: 'a', refreshToken: 'r'); // → authenticated
      await controller.drop();       // → unauthenticated

      final states = await eventsFuture;
      expect(states.length, 3);
      expect(states[0], isA<SessionUnauthenticated>());
      expect(states[1], isA<SessionAuthenticated>());
      expect(states[2], isA<SessionUnauthenticated>());
    });
  });
}
