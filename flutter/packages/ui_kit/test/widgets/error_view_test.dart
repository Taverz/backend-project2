import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ErrorView', () {
    testWidgets('отображает сообщение об ошибке', (tester) async {
      await tester.pumpWidget(
        _wrap(const ErrorView(message: 'Нет соединения')),
      );

      expect(find.text('Нет соединения'), findsOneWidget);
    });

    testWidgets('отображает иконку ошибки', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorView(message: 'Ошибка')));

      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('без onRetry — кнопка "Повторить" не отображается', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ErrorView(message: 'Ошибка')));

      expect(find.text('Повторить'), findsNothing);
    });

    testWidgets('с onRetry — кнопка "Повторить" отображается', (tester) async {
      await tester.pumpWidget(
        _wrap(ErrorView(message: 'Ошибка', onRetry: () {})),
      );

      expect(find.text('Повторить'), findsOneWidget);
    });

    testWidgets('нажатие "Повторить" вызывает onRetry', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(ErrorView(message: 'Ошибка', onRetry: () => tapped = true)),
      );

      await tester.tap(find.text('Повторить'));
      expect(tapped, isTrue);
    });

    testWidgets('виджет центрирован', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorView(message: 'Ошибка')));

      expect(find.byType(Center), findsWidgets);
    });
  });
}
