import '../gen/assets.gen.dart';

/// Каталог иконок UI-kit. Под капотом — сгенерированный `Assets.icons.*`
/// от flutter_gen, ассеты лежат в `packages/ui_kit/assets/icons/*.svg`.
/// Экраны не должны лезть в `Assets` напрямую — обращаться через `AppIcons`.
abstract final class AppIcons {
  static SvgGenImage get eyeOpen => Assets.icons.eyeOpen;
  static SvgGenImage get eyeClosed => Assets.icons.eyeClosed;
  static SvgGenImage get errorOutline => Assets.icons.errorOutline;
  static SvgGenImage get inboxOutline => Assets.icons.inboxOutline;
}
