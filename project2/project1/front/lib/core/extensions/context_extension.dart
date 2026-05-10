import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600;
}