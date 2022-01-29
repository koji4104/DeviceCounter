import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  static final double mobileWidth = 800.0;
  static final double desktopWidth = 1000.0;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  // This size work fine on my design, maybe you need some customization depends on your design
  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < mobileWidth;

  static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width < desktopWidth &&
    MediaQuery.of(context).size.width >= mobileWidth;

  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= desktopWidth;

  static Size getSize(BuildContext context) =>
      MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    // If our width is more than 1100 then we consider it a desktop
    if (_size.width >= desktopWidth) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (_size.width >= mobileWidth && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}
