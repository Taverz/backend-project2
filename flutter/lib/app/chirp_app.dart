import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'di/app_scope.dart';

class ChirpApp extends StatelessWidget {
  const ChirpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return MaterialApp.router(
      title: 'Chirp',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: scope.router,
    );
  }
}
