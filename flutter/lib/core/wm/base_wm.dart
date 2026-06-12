import 'dart:async';
import 'package:flutter/widgets.dart';

/// Базовый контракт для Widget Model.
/// WM = координатор экрана: держит Bloc'и, ValueNotifier'ы, подписки.
/// Бизнес-логики нет — только координация UI-стейта.
abstract class BaseWm {
  @mustCallSuper
  void init() {}

  @mustCallSuper
  void dispose() {}

  /// Добавь подписки в [_subscriptions], они закроются в dispose.
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  void addSubscription(StreamSubscription<dynamic> sub) => _subscriptions.add(sub);

  @protected
  void disposeSubscriptions() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
  }
}
