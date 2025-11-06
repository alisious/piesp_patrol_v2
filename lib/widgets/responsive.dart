import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Centruje treść i ogranicza max szerokość na web/desktop.
/// Na mobile zachowuje pełną szerokość + padding.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxContentWidth = 900,
    this.padding = const EdgeInsets.all(16),
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Padding(padding: padding, child: child);
    }
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// --- helpers do wykrywania szerokości ekranu ---
class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) => width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  /// Zwraca wartość zależnie od typu urządzenia (opcjonalnie tablet/desktop).
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

