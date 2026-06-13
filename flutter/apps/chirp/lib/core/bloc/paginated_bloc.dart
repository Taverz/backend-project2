import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class PaginatedEvent extends Equatable {
  const PaginatedEvent();
  @override
  List<Object?> get props => [];
}

class PaginatedRequested extends PaginatedEvent {
  const PaginatedRequested();
}

class PaginatedLoadMoreRequested extends PaginatedEvent {
  const PaginatedLoadMoreRequested();
}

class PaginatedRefreshRequested extends PaginatedEvent {
  const PaginatedRefreshRequested();
}

// ── State ─────────────────────────────────────────────────────────────────────

final class PaginatedState<T> extends Equatable {
  const PaginatedState({
    this.items = const [],
    this.cursor,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final List<T> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;

  bool get hasData => items.isNotEmpty;
  bool get hasError => failure != null;
  bool get isInitial => !isLoading && !hasData && !hasError;

  PaginatedState<T> copyWith({
    List<T>? items,
    String? Function()? cursor,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? Function()? failure,
  }) => PaginatedState<T>(
    items: items ?? this.items,
    cursor: cursor != null ? cursor() : this.cursor,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    items,
    cursor,
    hasMore,
    isLoading,
    isLoadingMore,
    failure,
  ];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

typedef PageData<T> = ({List<T> items, String? nextCursor});

abstract class PaginatedBloc<T>
    extends Bloc<PaginatedEvent, PaginatedState<T>> {
  PaginatedBloc() : super(PaginatedState<T>()) {
    on<PaginatedRequested>(_onRequested);
    on<PaginatedLoadMoreRequested>(
      _onLoadMore,
      // droppable: события во время активного обработчика дропаются, а не ставятся в очередь.
      transformer: droppable(),
    );
    on<PaginatedRefreshRequested>(_onRefresh);
  }

  /// Наследник реализует только этот метод. При ошибке — `throw Failure` (или
  /// любое исключение, оно будет обёрнуто в `UnknownFailure`).
  Future<PageData<T>> fetchPage(String? cursor);

  Future<void> _onRequested(
    PaginatedRequested _,
    Emitter<PaginatedState<T>> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: () => null));
    await _load(null, emit, append: false);
  }

  Future<void> _onLoadMore(
    PaginatedLoadMoreRequested _,
    Emitter<PaginatedState<T>> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    emit(state.copyWith(isLoadingMore: true));
    await _load(state.cursor, emit, append: true);
  }

  Future<void> _onRefresh(
    PaginatedRefreshRequested _,
    Emitter<PaginatedState<T>> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: () => null));
    await _load(null, emit, append: false);
  }

  Future<void> _load(
    String? cursor,
    Emitter<PaginatedState<T>> emit, {
    required bool append,
  }) async {
    try {
      final page = await fetchPage(cursor);
      emit(
        state.copyWith(
          items: append ? [...state.items, ...page.items] : page.items,
          cursor: () => page.nextCursor,
          hasMore: page.nextCursor != null,
          isLoading: false,
          isLoadingMore: false,
          failure: () => null,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          failure: () => failure,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          failure: () => const UnknownFailure(),
        ),
      );
    }
  }
}
