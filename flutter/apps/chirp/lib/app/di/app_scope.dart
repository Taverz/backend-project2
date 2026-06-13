import 'package:app_api/app_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_factory.dart';
import '../../core/session/session_controller.dart';
import '../../core/session/token_storage.dart';
import '../../core/storage/prefs_storage.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../router/app_router.dart';

/// Глобальные зависимости, которые живут всё время работы приложения.
///
/// Сюда складываются ВСЕ repositories / services / usecases — фичи не
/// собирают свою цепочку DI сами. Низкоуровневые транспорты (`Dio`,
/// `AppApiClient`) приватные внутри `_AppScopeHolderState` — наружу не
/// отдаются, чтобы экраны не лезли в них напрямую.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.session,
    required this.prefs,
    required this.router,
    required this.authRepository,
    required this.loginUseCase,
    required this.registerUseCase,
    required super.child,
  });

  // Инфраструктура
  final SessionController session;
  final PrefsStorage prefs;
  final GoRouter router;

  // Auth
  final AuthRepository authRepository;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  /// Lookup без подписки на изменения — разрешён в `initState`.
  static AppScope read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AppScope>();
    assert(element != null, 'AppScope not found in widget tree');
    return element!.widget as AppScope;
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
  // Инфраструктура (наружу не отдаётся)
  late final SessionController _session;
  late final Dio _dio;
  late final AppApiClient _api;
  late final PrefsStorage _prefs;
  late final GoRouter _router;

  // Auth
  late final AuthRepository _authRepository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  bool _ready = false;
  Object? _initError;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void dispose() {
    if (_ready) {
      _session.dispose();
      _dio.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: _InitErrorView(
          error: _initError!,
          onRetry: () {
            setState(() {
              _initError = null;
              _ready = false;
            });
            _initAsync();
          },
        ),
      );
    }
    if (!_ready) {
      return const SizedBox.shrink();
    }
    return AppScope(
      session: _session,
      prefs: _prefs,
      router: _router,
      authRepository: _authRepository,
      loginUseCase: _loginUseCase,
      registerUseCase: _registerUseCase,
      child: widget.child,
    );
  }

  Future<void> _initAsync() async {
    try {
      // ── Инфраструктура ─────────────────────────────────────────────────────
      const secureStorage = FlutterSecureStorage();
      const tokenStorage = TokenStorage(secureStorage);
      _session = SessionController(tokenStorage);

      final sharedPrefs = await SharedPreferences.getInstance();
      _prefs = PrefsStorage(sharedPrefs);

      _dio = DioFactory.create(
        baseUrl: const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://localhost:8080',
        ),
        session: _session,
      );

      // Флаг для оффлайн-разработки: `--dart-define=USE_MOCK_API=true`
      // подменяет реальный HTTP-клиент на `MockAppApiClient` с фикстурами.
      const useMock = bool.fromEnvironment('USE_MOCK_API');
      _api = useMock
          ? const MockAppApiClient()
          : AppApiClientImpl(dio: _dio);

      _router = buildRouter(_session);

      // ── Auth feature ───────────────────────────────────────────────────────
      // RemoteDataSource приходит готовым из AppApiClient — фича его не оборачивает.
      _authRepository = AuthRepositoryImpl(_api.auth);
      _loginUseCase = LoginUseCase(_authRepository, _session);
      _registerUseCase = RegisterUseCase(_authRepository, _session);

      await _session.init();

      if (mounted) setState(() => _ready = true);
    } catch (e, stack) {
      debugPrint('[AppScopeHolder] initialization failed: $e\n$stack');
      if (mounted) setState(() => _initError = e);
    }
  }
}

class _InitErrorView extends StatelessWidget {
  const _InitErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFFFFFFF),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Не удалось запустить приложение'),
          const SizedBox(height: 16),
          GestureDetector(onTap: onRetry, child: const Text('Повторить')),
        ],
      ),
    ),
  );
}
