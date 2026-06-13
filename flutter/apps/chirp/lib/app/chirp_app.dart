import 'package:flutter/material.dart';
import 'package:qa_tools_flutter/flutter_debug_tools.dart';
import 'package:ui_kit/ui_kit.dart';

import 'di/app_scope.dart';

class ChirpApp extends StatelessWidget {
  const ChirpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FlutterLens(
      // Оверлей появляется только в debug-сборке (kDebugMode — дефолт FlutterLens).
      // В release он не активен; сетевые/логовые перехватчики тоже только debug.
      builder: (context, _, __) => MaterialApp.router(
        title: 'Chirp',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: scope.router,
      ),
    );
  }
}
