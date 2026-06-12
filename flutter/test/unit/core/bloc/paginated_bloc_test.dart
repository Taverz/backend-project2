import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/bloc/paginated_bloc.dart';
import 'package:chirp/core/result/result.dart';
import 'package:chirp/core/error/failures.dart';

class _TestBloc extends PaginatedBloc<String> {
  _TestBloc(this._fetcher);
  final Future<Result<({List<String> items, String? nextCursor})>> Function(
    String?,
  )
  _fetcher;

  @override
  PageResult<String> fetchPage(String? cursor) => _fetcher(cursor);
}

void main() {
  group('PaginatedBloc', () {
    blocTest<_TestBloc, PaginatedState<String>>(
      'загружает первую страницу по PaginatedRequested',
      build: () => _TestBloc(
        (_) async => const Ok((items: ['a', 'b'], nextCursor: 'c2')),
      ),
      act: (bloc) => bloc.add(const PaginatedRequested()),
      expect: () => [
        const PaginatedState<String>(isLoading: true),
        const PaginatedState<String>(items: ['a', 'b'], cursor: 'c2'),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'добавляет элементы при LoadMore',
      build: () {
        int call = 0;
        return _TestBloc((_) async {
          call++;
          if (call == 1) return const Ok((items: ['a', 'b'], nextCursor: 'c2'));
          return const Ok((items: ['c', 'd'], nextCursor: null));
        });
      },
      act: (bloc) async {
        bloc.add(const PaginatedRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PaginatedLoadMoreRequested());
      },
      skip: 2,
      expect: () => [
        isA<PaginatedState<String>>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          true,
        ),
        isA<PaginatedState<String>>()
            .having((s) => s.items, 'items', ['a', 'b', 'c', 'd'])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'droppable: второй LoadMore дропается пока первый выполняется',
      build: () {
        int fetchCount = 0;
        return _TestBloc((_) async {
          fetchCount++;
          // Задержка только для LoadMore — чтобы второй прилетел пока первый ещё идёт.
          if (fetchCount > 1) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          return Ok((items: ['item$fetchCount'], nextCursor: 'next'));
        });
      },
      act: (bloc) async {
        bloc.add(const PaginatedRequested());
        await Future<void>.delayed(
          const Duration(milliseconds: 20),
        ); // Requested быстрый
        bloc.add(const PaginatedLoadMoreRequested()); // стартует 50ms фетч
        bloc.add(const PaginatedLoadMoreRequested()); // дропается droppable
        // Ждём завершения фетча внутри act — иначе blocTest закончит сбор стейтов раньше.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      },
      skip: 2,
      verify: (bloc) {
        // item1 (Requested) + item2 (один LoadMore).
        // Если второй LoadMore тоже прошёл — было бы 3 элемента.
        expect(bloc.state.items.length, equals(2));
      },
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'ошибка: isLoading сбрасывается, failure устанавливается, items сохраняются',
      build: () => _TestBloc((_) async => const Err(NetworkFailure())),
      act: (bloc) => bloc.add(const PaginatedRequested()),
      skip: 1,
      expect: () => [
        isA<PaginatedState<String>>()
            .having((s) => s.hasError, 'hasError', true)
            .having((s) => s.failure, 'failure', isA<NetworkFailure>())
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'Refresh сбрасывает список, очищает failure и загружает заново',
      build: () {
        int call = 0;
        return _TestBloc((_) async {
          call++;
          return Ok((items: ['item$call'], nextCursor: null));
        });
      },
      seed: () => const PaginatedState<String>(
        items: ['old'],
        failure: NetworkFailure(), // failure должно быть сброшено
      ),
      act: (bloc) => bloc.add(const PaginatedRefreshRequested()),
      expect: () => [
        isA<PaginatedState<String>>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.failure, 'failure', isNull),
        isA<PaginatedState<String>>()
            .having((s) => s.items, 'items', ['item1'])
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.failure, 'failure', isNull),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'нет hasMore когда nextCursor == null',
      build: () =>
          _TestBloc((_) async => const Ok((items: ['only'], nextCursor: null))),
      act: (bloc) => bloc.add(const PaginatedRequested()),
      skip: 1,
      expect: () => [
        isA<PaginatedState<String>>()
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.items, 'items', ['only']),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'LoadMore при hasMore=false игнорируется',
      build: () =>
          _TestBloc((_) async => const Ok((items: ['x'], nextCursor: null))),
      seed: () => const PaginatedState<String>(items: ['x'], hasMore: false),
      act: (bloc) => bloc.add(const PaginatedLoadMoreRequested()),
      expect: () => [],
    );
  });
}
