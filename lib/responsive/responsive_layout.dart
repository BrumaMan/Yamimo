import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout(
      {super.key, required this.mobileLayout, required this.desktopLayout});

  final Widget mobileLayout;
  final Widget desktopLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((p0, constraints) {
      if (constraints.maxWidth > 600) {
        return desktopLayout;
      } else {
        return mobileLayout;
      }
    }));
  }
}
