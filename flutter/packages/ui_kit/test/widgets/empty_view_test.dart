import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EmptyView', () {
    testWidgets('отображает сообщение', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyView(message: 'Ничего нет')));

      expect(find.text('Ничего нет'), findsOneWidget);
    });

    testWidgets('отображает иконку по умолчанию (inbox)', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyView(message: 'Пусто')));

      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('отображает кастомную иконку', (tester) async {
      await tester.pumpWidget(
        _wrap(
          EmptyView(
            message: 'Нет уведомлений',
            icon: AppIcons.errorOutline,
          ),
        ),
      );

      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('виджет центрирован', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyView(message: 'Пусто')));

      expect(find.byType(Center), findsWidgets);
    });
  });
}
