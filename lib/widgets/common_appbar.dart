import 'package:flutter/material.dart';

/// Reużywalny AppBar (Material 3)
/// - opcjonalny przycisk wstecz
/// - akcje po prawej
/// - opcjonalny dolny pasek (np. TabBar)
/// - centerTitle automatycznie na szerokich ekranach
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.showBack = false,
    this.actions = const <Widget>[],
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,      
    this.surfaceTintColor,      
    this.centerTitle, // jeśli null: auto (mobile=false, szerokie=true)
    this.elevation,
    this.scrolledUnderElevation,
  });

  final String title;
  final Widget? leading;
  final bool showBack;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor; 
  final Color? surfaceTintColor;
  final bool? centerTitle;
  final double? elevation;
  final double? scrolledUnderElevation;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final autoCenter = width >= 800;
    final effectiveCenter = centerTitle ?? autoCenter;

    final Widget? effectiveLeading =
        leading ?? (showBack ? const BackButton() : null);

    return AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      centerTitle: effectiveCenter,
      leading: effectiveLeading,
      actions: actions,
      bottom: bottom,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,        
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
    );
  }
}

/// Prosty wrapper na TabBar
class CommonTabs extends StatelessWidget implements PreferredSizeWidget {
  const CommonTabs({
    super.key,
    required this.tabs,
    this.isScrollable = true,
    this.indicatorColor,
  });

  final List<Widget> tabs;
  final bool isScrollable;
  final Color? indicatorColor;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TabBar(
      isScrollable: isScrollable,
      indicatorColor: indicatorColor ?? scheme.primary,
      tabs: tabs,
    );
  }
}
