import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/app_app_bar_use_cases.dart';
import 'use_cases/app_button_use_cases.dart';
import 'use_cases/app_icon_use_cases.dart';
import 'use_cases/app_loader_use_cases.dart';
import 'use_cases/app_snack_bar_use_cases.dart';
import 'use_cases/app_text_field_use_cases.dart';
import 'use_cases/catalog_use_cases.dart';
import 'use_cases/empty_view_use_cases.dart';
import 'use_cases/error_view_use_cases.dart';
import 'use_cases/templates_use_cases.dart';

void main() => runApp(const StorybookApp());

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildWidgetbook(context);
  }

  Widget _buildWidgetbook(BuildContext context) {
    return Widgetbook.material(
      addons: [
        ThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light()),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark()),
          ],
          themeBuilder: (context, theme, child) =>
              Theme(data: theme, child: child),
        ),
      ],
      directories: [
        WidgetbookComponent(
          name: 'Main',
          useCases: catalogUseCases,
        ),
        WidgetbookCategory(
          name: '⚛️ Atoms',
          children: [
            WidgetbookComponent(
              name: 'AppButton',
              useCases: appButtonUseCases,
            ),
            WidgetbookComponent(
              name: 'AppTextField',
              useCases: appTextFieldUseCases,
            ),
            WidgetbookComponent(name: 'AppIcon', useCases: appIconUseCases),
            WidgetbookComponent(
              name: 'AppLoader',
              useCases: appLoaderUseCases,
            ),
          ],
        ),
        WidgetbookCategory(
          name: '🧬 Molecules',
          children: [
            WidgetbookComponent(
              name: 'AppAppBar',
              useCases: appAppBarUseCases,
            ),
            WidgetbookComponent(
              name: 'AppSnackBar',
              useCases: appSnackBarUseCases,
            ),
          ],
        ),
        WidgetbookCategory(
          name: '🦠 Organisms',
          children: [
            WidgetbookComponent(
              name: 'ErrorView',
              useCases: errorViewUseCases,
            ),
            WidgetbookComponent(
              name: 'EmptyView',
              useCases: emptyViewUseCases,
            ),
          ],
        ),
        WidgetbookCategory(
          name: '📄 Templates',
          children: [
            WidgetbookFolder(
              name: 'auth',
              children: [
                WidgetbookComponent(
                  name: 'LoginTemplate',
                  useCases: loginTemplateUseCases,
                ),
                WidgetbookComponent(
                  name: 'RegisterTemplate',
                  useCases: registerTemplateUseCases,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
