import 'package:flutter/material.dart';

import '../molecules/app_snack_bar.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Показывает кастомный AppSnackBar через Overlay (не Material SnackBar).
  void showSnackBar(String message, {bool isError = false}) {
    AppSnackBar.show(this, message: message, isError: isError);
  }
}
