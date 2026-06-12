import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'Roboto';

  static const headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const body1 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const body2 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}
