import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets all14 = EdgeInsets.all(14);
  static const EdgeInsets all18 = EdgeInsets.all(18);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets all20 = EdgeInsets.all(xl);
  static const EdgeInsets all24 = EdgeInsets.all(xxl);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);
  static const EdgeInsets horizontal16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontal36 = EdgeInsets.symmetric(horizontal: 36);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets onlyBottom12 = EdgeInsets.only(bottom: md);
  static const EdgeInsets horizontal16Vertical14 =
      EdgeInsets.symmetric(horizontal: lg, vertical: 14);
}
