import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/shared/widgets/empty_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EmptyView', () {
    testWidgets('отображает сообщение', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyView(message: 'Ничего нет'),
      ));

      expect(find.text('Ничего нет'), findsOneWidget);
    });

    testWidgets('отображает иконку по умолчанию (inbox)', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyView(message: 'Пусто'),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('отображает кастомную иконку', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyView(
          message: 'Нет уведомлений',
          icon: Icons.notifications_off_outlined,
        ),
      ));

      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });

    testWidgets('виджет центрирован', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyView(message: 'Пусто'),
      ));

      expect(find.byType(Center), findsWidgets);
    });
  });
}
