import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../../core/network/dio_factory.dart';
import '../../core/session/session_controller.dart';
import '../../core/session/token_storage.dart';
import '../../core/storage/prefs_storage.dart';
import '../router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Глобальные зависимости, которые живут всё время работы приложения.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.session,
    required this.dio,
    required this.prefs,
    required this.router,
    required super.child,
  });

  final SessionController session;
  final Dio dio;
  final PrefsStorage prefs;
  final GoRouter router;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}

class AppScopeHolder extends StatefulWidget {
  const AppScopeHolder({super.key, required this.child});
  final Widget child;

  @override
  State<AppScopeHolder> createState() => _AppScopeHolderState();
}

class _AppScopeHolderState extends State<AppScopeHolder> {
  late final SessionController _session;
  late final Dio _dio;
  late final PrefsStorage _prefs;
  late final GoRouter _router;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    _session = SessionController(tokenStorage);

    final sharedPrefs = await SharedPreferences.getInstance();
    _prefs = PrefsStorage(sharedPrefs);

    _dio = DioFactory.create(
      baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080'),
      session: _session,
    );

    _router = buildRouter(_session);

    await _session.init();

    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _session.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox.shrink();
    }
    return AppScope(
      session: _session,
      dio: _dio,
      prefs: _prefs,
      router: _router,
      child: widget.child,
    );
  }
}
