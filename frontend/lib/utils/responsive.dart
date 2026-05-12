import 'package:flutter/material.dart';

class Responsive {

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallPhone(BuildContext context) {
    return width(context) < 380;
  }

  static bool isTablet(BuildContext context) {
    return width(context) > 600;
  }
}