import 'package:flutter/material.dart';
import 'package:qa_tools_flutter/flutter_debug_tools.dart';
import 'package:ui_kit/ui_kit.dart';

import 'di/app_scope.dart';

class ChirpApp extends StatelessWidget {
  const ChirpApp({super.key});

  // Оверлей FlutterLens включается только по явному флагу
  // `--dart-define=QA_TOOLS=true`, чтобы обычный `chirp · debug` его не тянул.
  static const _qaToolsEnabled = bool.fromEnvironment('QA_TOOLS');

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final app = MaterialApp.router(
      title: 'Chirp',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: scope.router,
    );
    if (!_qaToolsEnabled) return app;
    return FlutterLens(builder: (context, _, __) => app);
  }
}
