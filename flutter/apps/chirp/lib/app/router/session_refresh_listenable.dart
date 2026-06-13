import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/session/session_controller.dart';

/// Адаптер SessionController → Listenable для GoRouter.refreshListenable.
class SessionRefreshListenable extends ChangeNotifier {
  SessionRefreshListenable(SessionController session) {
    _sub = session.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
