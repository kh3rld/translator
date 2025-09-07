import 'package:flutter/material.dart';

class ResponsiveTheme {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Screen size detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Responsive values
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isDesktop(context)) return 3;
    return 4;
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
      largeDesktop: largeDesktop ?? mobile * 1.3,
    );
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    return getResponsiveValue(
      context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.5,
      largeDesktop: baseSpacing * 2.0,
    );
  }

  // Responsive border radius
  static double getBorderRadius(BuildContext context, double baseRadius) {
    return getResponsiveValue(
      context,
      mobile: baseRadius,
      tablet: baseRadius * 1.1,
      desktop: baseRadius * 1.2,
      largeDesktop: baseRadius * 1.3,
    );
  }

  // Responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    return getResponsiveValue(
      context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
      largeDesktop: baseSize * 1.3,
    );
  }

  // Responsive grid layout
  static Widget buildResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
  }) {
    final responsiveSpacing = getSpacing(context, spacing);
    final responsiveRunSpacing = getSpacing(context, runSpacing);

    if (isMobile(context)) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(bottom: responsiveRunSpacing),
                  child: child,
                ))
            .toList(),
      );
    }

    return Wrap(
      spacing: responsiveSpacing,
      runSpacing: responsiveRunSpacing,
      children: children,
    );
  }

  // Responsive card layout
  static Widget buildResponsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? elevation,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    final responsivePadding = padding ??
        getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
          largeDesktop: const EdgeInsets.all(32),
        );

    final responsiveElevation = elevation ??
        getResponsiveValue(
          context,
          mobile: 2.0,
          tablet: 4.0,
          desktop: 6.0,
          largeDesktop: 8.0,
        );

    final responsiveBorderRadius = borderRadius ??
        BorderRadius.circular(
          getBorderRadius(context, 12),
        );

    return Card(
      elevation: responsiveElevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: responsiveBorderRadius,
      ),
      child: Padding(
        padding: responsivePadding,
        child: child,
      ),
    );
  }

  // Responsive text styles
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required TextStyle baseStyle,
    double? tabletScale,
    double? desktopScale,
    double? largeDesktopScale,
  }) {
    final scale = getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: tabletScale ?? 1.1,
      desktop: desktopScale ?? 1.2,
      largeDesktop: largeDesktopScale ?? 1.3,
    );

    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scale,
    );
  }

  // Responsive button styles
  static ButtonStyle getResponsiveButtonStyle(
    BuildContext context, {
    required Color backgroundColor,
    required Color foregroundColor,
    double? elevation,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    final responsivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: getSpacing(context, 24),
          vertical: getSpacing(context, 12),
        );

    final responsiveElevation = elevation ??
        getResponsiveValue(
          context,
          mobile: 2.0,
          tablet: 3.0,
          desktop: 4.0,
          largeDesktop: 5.0,
        );

    final responsiveBorderRadius = borderRadius ??
        BorderRadius.circular(
          getBorderRadius(context, 8),
        );

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: responsiveElevation,
      padding: responsivePadding,
      shape: RoundedRectangleBorder(
        borderRadius: responsiveBorderRadius,
      ),
    );
  }

  // Responsive dialog
  static Widget buildResponsiveDialog({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double dialogWidth;
    double dialogHeight;

    if (isMobile(context)) {
      dialogWidth = screenWidth * 0.9;
      dialogHeight = screenHeight * 0.8;
    } else if (isTablet(context)) {
      dialogWidth = screenWidth * 0.7;
      dialogHeight = screenHeight * 0.7;
    } else {
      dialogWidth = screenWidth * 0.5;
      dialogHeight = screenHeight * 0.6;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getBorderRadius(context, 16)),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(16),
                  tablet: const EdgeInsets.all(20),
                  desktop: const EdgeInsets.all(24),
                ),
                child: Text(
                  title,
                  style: getResponsiveTextStyle(
                    context,
                    baseStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.symmetric(horizontal: 16),
                  tablet: const EdgeInsets.symmetric(horizontal: 20),
                  desktop: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: child,
              ),
            ),
            if (actions != null)
              Padding(
                padding: getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(16),
                  tablet: const EdgeInsets.all(20),
                  desktop: const EdgeInsets.all(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Responsive list view
  static Widget buildResponsiveListView({
    required BuildContext context,
    required List<Widget> children,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    final responsivePadding = padding ??
        getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
          largeDesktop: const EdgeInsets.all(32),
        );

    if (isMobile(context)) {
      return ListView(
        controller: controller,
        shrinkWrap: shrinkWrap,
        padding: responsivePadding,
        children: children,
      );
    } else {
      return GridView.builder(
        controller: controller,
        shrinkWrap: shrinkWrap,
        padding: responsivePadding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getResponsiveColumns(context),
          crossAxisSpacing: getSpacing(context, 16),
          mainAxisSpacing: getSpacing(context, 16),
          childAspectRatio: isTablet(context) ? 1.2 : 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    }
  }

  // Responsive app bar
  static PreferredSizeWidget buildResponsiveAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    double? elevation,
  }) {
    final responsiveElevation = elevation ??
        getResponsiveValue(
          context,
          mobile: 4.0,
          tablet: 6.0,
          desktop: 8.0,
          largeDesktop: 10.0,
        );

    return AppBar(
      title: Text(
        title,
        style: getResponsiveTextStyle(
          context,
          baseStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: responsiveElevation,
    );
  }

  // Responsive bottom navigation
  static Widget buildResponsiveBottomNavigation({
    required BuildContext context,
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<BottomNavigationBarItem> items,
  }) {
    if (isMobile(context)) {
      return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        type: BottomNavigationBarType.fixed,
      );
    } else {
      return NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: items
            .map((item) => NavigationRailDestination(
                  icon: item.icon,
                  label: Text(item.label ?? ''),
                ))
            .toList(),
      );
    }
  }
}
