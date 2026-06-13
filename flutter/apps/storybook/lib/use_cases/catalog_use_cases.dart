import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

// ignore_for_file: prefer_const_constructors

/// Каталог-страницы для визуального обзора всего ui_kit на одной странице.
/// Используются как «оглавление» — быстро найти нужный компонент глазами.

final catalogUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'All Primitives',
    builder: (_) => const _AllPrimitives(),
  ),
  WidgetbookUseCase(
    name: 'All Composites',
    builder: (_) => const _AllComposites(),
  ),
  WidgetbookUseCase(name: 'Color tokens', builder: (_) => const _ColorTokens()),
  WidgetbookUseCase(
    name: 'Typography',
    builder: (_) => const _TypographyCatalog(),
  ),
];

// ── Catalog views ────────────────────────────────────────────────────────────

class _AllPrimitives extends StatelessWidget {
  const _AllPrimitives();

  @override
  Widget build(BuildContext context) {
    return _CatalogScroll(
      children: [
        _Section(
          name: 'AppButton (primary / secondary / disabled / loading)',
          child: Row(
            children: [
              Expanded(
                child: AppButton(label: 'Войти', onPressed: () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Отмена',
                  kind: AppButtonKind.secondary,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: AppButton(label: 'Disabled', onPressed: null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Loading',
                  isLoading: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        _Section(
          name: 'AppTextButton',
          child: AppTextButton(label: 'Нет аккаунта?', onPressed: () {}),
        ),
        _Section(
          name: 'AppTextField (default / with error / disabled / password)',
          child: Column(
            children: [
              const AppTextField(label: 'Email'),
              const SizedBox(height: 12),
              const AppTextField(label: 'Email', errorText: 'Неверный формат'),
              const SizedBox(height: 12),
              const AppTextField(label: 'Email', enabled: false),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Пароль',
                obscureText: true,
                suffix: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AppIcon(AppIcons.eyeOpen),
                ),
              ),
            ],
          ),
        ),
        _Section(
          name: 'AppLoader (small / medium / large)',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              AppLoader(size: 16),
              AppLoader(),
              AppLoader(size: 48, strokeWidth: 4),
            ],
          ),
        ),
        _Section(
          name: 'AppIcon (catalog)',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _IconTile('eyeOpen', AppIcons.eyeOpen),
              _IconTile('eyeClosed', AppIcons.eyeClosed),
              _IconTile('errorOutline', AppIcons.errorOutline),
              _IconTile('inboxOutline', AppIcons.inboxOutline),
            ],
          ),
        ),
        _Section(
          name: 'AppAppBar',
          child: AppAppBar(
            title: 'Профиль',
            actions: [AppIcon(AppIcons.eyeOpen)],
          ),
        ),
        _Section(
          name: 'AppSnackBar — тригер',
          child: Center(
            child: AppButton(
              label: 'Показать snack',
              onPressed: () => AppSnackBar.show(context, message: 'Сохранено'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AllComposites extends StatelessWidget {
  const _AllComposites();

  @override
  Widget build(BuildContext context) {
    return _CatalogScroll(
      children: [
        _Section(
          name: 'ErrorView (с retry)',
          height: 200,
          child: ErrorView(message: 'Что-то пошло не так', onRetry: () {}),
        ),
        _Section(
          name: 'EmptyView',
          height: 200,
          child: const EmptyView(message: 'Пока ничего нет'),
        ),
      ],
    );
  }
}

class _ColorTokens extends StatelessWidget {
  const _ColorTokens();

  @override
  Widget build(BuildContext context) {
    const tokens = <(String, Color)>[
      ('primary', AppColors.primary),
      ('primaryDark', AppColors.primaryDark),
      ('background', AppColors.background),
      ('backgroundDark', AppColors.backgroundDark),
      ('surface', AppColors.surface),
      ('surfaceDark', AppColors.surfaceDark),
      ('border', AppColors.border),
      ('borderDark', AppColors.borderDark),
      ('textPrimary', AppColors.textPrimary),
      ('textSecondary', AppColors.textSecondary),
      ('textPrimaryDark', AppColors.textPrimaryDark),
      ('textSecondaryDark', AppColors.textSecondaryDark),
      ('error', AppColors.error),
      ('success', AppColors.success),
      ('like', AppColors.like),
    ];

    return _CatalogScroll(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (name, color) in tokens)
              _ColorSwatch(name: name, color: color),
          ],
        ),
      ],
    );
  }
}

class _TypographyCatalog extends StatelessWidget {
  const _TypographyCatalog();

  @override
  Widget build(BuildContext context) {
    final styles = <(String, TextStyle)>[
      ('headline1', AppTypography.headline1),
      ('headline2', AppTypography.headline2),
      ('body1', AppTypography.body1),
      ('body2', AppTypography.body2),
      ('label', AppTypography.label),
      ('button', AppTypography.button),
    ];

    return _CatalogScroll(
      children: [
        for (final (name, style) in styles)
          _Section(
            name: name,
            child: Text('Aa Бб 123 — $name', style: style),
          ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _CatalogScroll extends StatelessWidget {
  const _CatalogScroll({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.name, required this.child, this.height});

  final String name;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text(name, style: AppTypography.label),
        ),
        Container(
          height: height,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    ),
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile(this.name, this.icon);
  final String name;
  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppIcon(icon, size: 28),
      const SizedBox(height: 4),
      Text(name, style: AppTypography.label),
    ],
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 140,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: AppTypography.label),
        Text(
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  );
}
