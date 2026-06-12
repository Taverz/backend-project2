import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[BlocObserver] ${bloc.runtimeType} error: $error');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<Object?> bloc, Change<Object?> change) {
    if (kDebugMode) {
      debugPrint(
        '[BlocObserver] ${bloc.runtimeType}: ${change.nextState.runtimeType}',
      );
    }
    super.onChange(bloc, change);
  }
}
