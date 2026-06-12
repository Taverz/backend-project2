import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chirp/core/bloc/paginated_bloc.dart';
import 'package:chirp/core/result/result.dart';
import 'package:chirp/core/error/failures.dart';

// Конкретный Bloc для тестов
class _TestBloc extends PaginatedBloc<String> {
  _TestBloc(this._fetcher);

  final Future<Result<({List<String> items, String? nextCursor})>> Function(String? cursor)
      _fetcher;

  @override
  PageResult<String> fetchPage(String? cursor) => _fetcher(cursor);
}

void main() {
  group('PaginatedBloc', () {
    blocTest<_TestBloc, PaginatedState<String>>(
      'загружает первую страницу по PaginatedRequested',
      build: () => _TestBloc((_) async => const Ok((items: ['a', 'b'], nextCursor: 'c2'))),
      act: (bloc) => bloc.add(const PaginatedRequested()),
      expect: () => [
        const PaginatedState<String>(isLoading: true),
        const PaginatedState<String>(
          items: ['a', 'b'],
          cursor: 'c2',
          hasMore: true,
          isLoading: false,
        ),
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
        isA<PaginatedState<String>>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<PaginatedState<String>>()
            .having((s) => s.items, 'items', ['a', 'b', 'c', 'd'])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'игнорирует двойной LoadMore (droppable)',
      build: () {
        int fetchCount = 0;
        return _TestBloc((_) async {
          fetchCount++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Ok((items: ['item$fetchCount'], nextCursor: 'next'));
        });
      },
      act: (bloc) async {
        bloc.add(const PaginatedRequested());
        await Future<void>.delayed(Duration.zero);
        // Два LoadMore почти одновременно — второй должен быть дропнут
        bloc.add(const PaginatedLoadMoreRequested());
        bloc.add(const PaginatedLoadMoreRequested());
      },
      skip: 2,
      verify: (bloc) {
        // Только один LoadMore должен был пройти
        expect(bloc.state.items.length, lessThanOrEqualTo(2));
      },
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'эмитит состояние ошибки при сбое',
      build: () => _TestBloc((_) async => const Err(NetworkFailure())),
      act: (bloc) => bloc.add(const PaginatedRequested()),
      skip: 1,
      expect: () => [
        isA<PaginatedState<String>>()
            .having((s) => s.hasError, 'hasError', true)
            .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'Refresh сбрасывает список и загружает заново',
      build: () {
        int call = 0;
        return _TestBloc((_) async {
          call++;
          return Ok((items: ['item$call'], nextCursor: null));
        });
      },
      act: (bloc) async {
        bloc.add(const PaginatedRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PaginatedRefreshRequested());
      },
      skip: 2,
      expect: () => [
        isA<PaginatedState<String>>().having((s) => s.isLoading, 'isLoading', true),
        isA<PaginatedState<String>>()
            .having((s) => s.items, 'items', ['item2'])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<_TestBloc, PaginatedState<String>>(
      'нет hasMore когда nextCursor == null',
      build: () => _TestBloc((_) async => const Ok((items: ['only'], nextCursor: null))),
      act: (bloc) => bloc.add(const PaginatedRequested()),
      skip: 1,
      expect: () => [
        isA<PaginatedState<String>>()
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.items, 'items', ['only']),
      ],
    );
  });
}
