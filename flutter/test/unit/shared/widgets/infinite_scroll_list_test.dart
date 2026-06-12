import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/shared/widgets/infinite_scroll_list.dart';

Widget _buildList({
  required List<String> items,
  required VoidCallback onLoadMore,
  bool hasMore = true,
  bool isLoadingMore = false,
}) => MaterialApp(
  home: Scaffold(
    body: InfiniteScrollList<String>(
      items: items,
      itemBuilder: (_, item) => ListTile(key: Key(item), title: Text(item)),
      onLoadMore: onLoadMore,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
    ),
  ),
);

void main() {
  group('InfiniteScrollList', () {
    testWidgets('рендерит все элементы', (tester) async {
      await tester.pumpWidget(
        _buildList(items: ['alpha', 'beta', 'gamma'], onLoadMore: () {}),
      );

      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
      expect(find.text('gamma'), findsOneWidget);
    });

    testWidgets('isLoadingMore=true показывает индикатор загрузки', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildList(items: ['item1'], onLoadMore: () {}, isLoadingMore: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('isLoadingMore=false скрывает индикатор', (tester) async {
      await tester.pumpWidget(_buildList(items: ['item1'], onLoadMore: () {}));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('пустой список не крашится', (tester) async {
      await tester.pumpWidget(_buildList(items: [], onLoadMore: () {}));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('onLoadMore не вызывается при hasMore=false и скролле', (
      tester,
    ) async {
      int calls = 0;
      final items = List.generate(5, (i) => 'item$i');

      await tester.pumpWidget(
        _buildList(items: items, onLoadMore: () => calls++, hasMore: false),
      );

      // Скроллим до конца
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      expect(calls, 0);
    });

    testWidgets('onLoadMore не вызывается пока isLoadingMore=true', (
      tester,
    ) async {
      int calls = 0;
      final items = List.generate(30, (i) => 'item$i');

      await tester.pumpWidget(
        _buildList(
          items: items,
          onLoadMore: () => calls++,
          // hasMore: true — дефолт, но isLoadingMore: true обязателен для теста
          isLoadingMore: true,
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      expect(calls, 0);
    });

    testWidgets('onLoadMore вызывается при скролле к концу списка', (
      tester,
    ) async {
      // Позитивный тест: проверяем что триггер РАБОТАЕТ, а не только защищён.
      int calls = 0;
      final items = List.generate(50, (i) => 'item$i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: InfiniteScrollList<String>(
                items: items,
                itemBuilder: (_, item) => ListTile(title: Text(item)),
                onLoadMore: () => calls++,
                hasMore: true,
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      expect(calls, greaterThan(0));
    });
  });
}
