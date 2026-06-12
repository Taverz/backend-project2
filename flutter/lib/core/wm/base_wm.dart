import 'dart:async';
import 'package:flutter/widgets.dart';

/// Базовый контракт для Widget Model.
/// WM = координатор экрана: держит Bloc'и, ValueNotifier'ы, подписки.
/// Бизнес-логики нет — только координация UI-стейта.
abstract class BaseWm {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @mustCallSuper
  void init() {}

  /// Добавь подписки через этот метод — они закроются автоматически в dispose.
  void addSubscription(StreamSubscription<dynamic> sub) =>
      _subscriptions.add(sub);

  @mustCallSuper
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
  }
}
