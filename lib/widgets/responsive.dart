// lib/responsive.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Progi szerokości (w pikselach)
const double kMobileBreakpoint = 600;
const double kTabletBreakpoint = 1024;

/// Globalny limit szerokości treści na web/desktop/tablet.
/// Ustaw tu szerokość, jaką mają mieć Twoje strony w przeglądarce.
/// Jeśli chcesz dopasować do panelu z ArrowButtonami – wpisz jego szerokość.
const double kWebMaxPageWidth = 960;

/// Klasa pomocnicza do wykrywania typu urządzenia na podstawie szerokości.
class Responsive {
  const Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < kMobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= kMobileBreakpoint && w < kTabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= kTabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;
}

/// Wygodne gettery na kontekście.
extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);

  double get screenWidth => Responsive.screenWidth(this);
  double get screenHeight => Responsive.screenHeight(this);
}

/// Kontener strony:
/// - Na web/desktop/tablet: centruje treść i ogranicza max szerokość do [maxWidth] (domyślnie [kWebMaxPageWidth]).
/// - Na Android/iOS (wąskie ekrany): daje pełną szerokość (bez ograniczeń),
///   więc UI zajmuje całą szerokość telefonu.
/// - Na większych telefonach/tabletach natywnie (gdy bardzo szeroko): również nałoży limit,
///   by uniknąć „rozlewania się” treści.
class PageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  const PageContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  bool _shouldConstrain(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // W przeglądarce zwykle chcemy ograniczać (ekrany bywają bardzo szerokie)
    if (kIsWeb) return true;

    // Na natywnych platformach ograniczamy, gdy ekran jest „szeroki” (tablet, landscape itp.)
    return width >= kMobileBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final applyConstraint = _shouldConstrain(context);
    final limit = maxWidth ?? kWebMaxPageWidth;

    if (!applyConstraint) {
      // Telefony / wąskie ekrany: pełna szerokość
      return Padding(
        padding: padding,
        child: child,
      );
    }

    // Web / desktop / tablet / szerokie ekrany: centrowany kontener z limitem szerokości
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: limit),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
