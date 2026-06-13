import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/chirp_app.dart';
import 'app/di/app_scope.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/observability/sentry_setup.dart';

void main() {
  SentrySetup.bootstrap(() {
    Bloc.observer = AppBlocObserver();
    runApp(const AppScopeHolder(child: ChirpApp()));
  });
}
