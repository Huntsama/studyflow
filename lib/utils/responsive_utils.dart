import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getContentPadding(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }

  static double getCardPadding(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }

  static double getItemSpacing(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 12.0;
    return 16.0;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double getGridAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.9;
    if (isTablet(context)) return 0.85;
    return 0.8;
  }

  static TextStyle getHeadingStyle(BuildContext context) {
    final theme = Theme.of(context);
    if (isMobile(context)) {
      return theme.textTheme.headlineSmall ?? const TextStyle();
    } else if (isTablet(context)) {
      return theme.textTheme.headlineMedium ?? const TextStyle();
    } else {
      return theme.textTheme.headlineLarge ?? const TextStyle();
    }
  }

  static TextStyle getBodyStyle(BuildContext context) {
    final theme = Theme.of(context);
    if (isMobile(context)) {
      return theme.textTheme.bodyMedium ?? const TextStyle();
    } else {
      return theme.textTheme.bodyLarge ?? const TextStyle();
    }
  }

  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 22.0;
    return 24.0;
  }

  static double getButtonMinHeight(BuildContext context) {
    if (isMobile(context)) return 48.0;
    return 52.0;
  }

  static EdgeInsets getListTilePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  static double getListTileHeight(BuildContext context) {
    if (isMobile(context)) return 64.0;
    if (isTablet(context)) return 72.0;
    return 80.0;
  }

  static bool shouldUseCompactLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200.0;
    return double.infinity;
  }

  static Widget adaptiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = getMaxContentWidth(context);

    if (screenWidth > maxWidth) {
      return Center(
        child: Container(
          width: maxWidth,
          padding: padding ?? getScreenPadding(context),
          child: child,
        ),
      );
    }

    return Container(
      padding: padding ?? getScreenPadding(context),
      child: child,
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final isTablet = ResponsiveUtils.isTablet(context);
        final isDesktop = ResponsiveUtils.isDesktop(context);

        return builder(context, isMobile, isTablet, isDesktop);
      },
    );
  }
}