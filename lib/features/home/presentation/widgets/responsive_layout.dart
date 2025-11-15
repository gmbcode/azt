import 'package:flutter/material.dart';

/// A helper widget to determine if the current screen is mobile or desktop
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  
  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}

/// Helper function to check if the current screen is mobile
bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 800;
}
