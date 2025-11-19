import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/duty/data/duty_controller.dart';

// zakładki
import 'package:piesp_patrol/features/home/tabs/services_tab.dart';
import 'package:piesp_patrol/features/home/tabs/duty_tab.dart';
import 'package:piesp_patrol/features/home/tabs/other_tab.dart';

// Uwaga: korzystamy z Twojego responsive.dart z metodami Responsive.isDesktop / isTablet
import 'package:piesp_patrol/widgets/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialTabIndex = 0,
  });

  /// Indeks zakładki do wyświetlenia przy starcie (0 = DutyTab, 1 = ServicesTab, 2 = OtherTab)
  final int initialTabIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    // Ustaw początkowy indeks zakładki (domyślnie 0, ale może być przekazany przez konstruktor)
    _index = widget.initialTabIndex.clamp(0, 2);
  }

  // Kontener ograniczający szerokość tylko na większych ekranach (web/desktop/tablet)
  Widget _responsiveShell(BuildContext context, Widget child) {
    final isWide = Responsive.isDesktop(context) || Responsive.isTablet(context);

    // Na mobile (Android) – pełna szerokość
    if (!isWide) {
      return child;
    }

    // Na web/desktop/tablet – wyśrodkowany, ograniczony maxWidth
    final maxWidth = Responsive.isDesktop(context) ? 460.0 : 460.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: child,
        ),
      ),
    );
  }

  List<Widget> get _tabs => const [
        DutyTab(),
        ServicesTab(),
        OtherTab(),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final services = AppScope.read(context);
    // Używamy read() aby uniknąć niepotrzebnych rebuildu przy notifyListeners() w AuthController
    final auth = services.authController as AuthController;
    final dutyController = services.dutyController as DutyController;
    final badge = auth.meProfile?.badgeNumber ?? '---';
    final name = auth.meProfile?.userName ?? '---';
       
    return Theme(
      // nie zmieniamy globalnego stylu, tylko dopieszczamy AppBar/NavBar
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: IconThemeData(color: cs.onPrimaryContainer),
          actionsIconTheme: IconThemeData(color: cs.onPrimaryContainer),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 56,
          backgroundColor: cs.surfaceContainerHigh,
          indicatorColor: cs.primaryContainer.withValues(alpha: 0.6),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 22,
              color: states.contains(WidgetState.selected)
                  ? cs.onPrimaryContainer
                  : cs.onSurfaceVariant,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: states.contains(WidgetState.selected)
                  ? cs.onSurface
                  : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 12,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10),
              Text('PIESP Patrol'),
              const SizedBox(width: 8),
            
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Wyloguj',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // bezpiecznie – bierzemy navigator przed await
                final navigator = Navigator.of(context);
                final auth = AppScope.read(context).authController as AuthController;
                await auth.logout();
                if (!mounted) return;
                navigator.pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (_) => false,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
    preferredSize: const Size.fromHeight(45), // było 56
    child: Container(
      width: double.infinity,
      color: cs.primary,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6), // było 8
      child: Row(
        children: [
          _InfoChip(
            bg: cs.surfaceContainerHighest,
            fg: cs.onSurface,
            icon: Icons.badge_outlined,
            label: badge,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoChip(
              bg: cs.surfaceContainerHighest,
              fg: cs.onSurface,
              icon: Icons.account_circle_outlined,
              label: name,
            ),
          ),
          AnimatedBuilder(
            animation: dutyController,
            builder: (context, _) {
              if (!dutyController.hasCurrentDuty) {
                return const SizedBox.shrink();
              }
              return Row(
                children: [
                  const SizedBox(width: 10),
                  _ChipIcon(
                    bg: cs.surfaceContainerHighest,
                    fg: cs.onSurfaceVariant,
                    icon: Icons.shield_outlined,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  ),
        ),

        body: SafeArea(
          child: _responsiveShell(
            context,
            // Dajemy lekkie przewijanie – ale nie psuje układu mobilnego
            ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _tabs[_index],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_moon),
              selectedIcon: Icon(Icons.shield_moon),
              label: 'Służba',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_document),
              selectedIcon: Icon(Icons.edit_document),
              label: 'Usługi',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'Inne',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon({
    required this.bg,
    required this.fg,
    required this.icon,
  });

  final Color bg;
  final Color fg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

/// Lokalny, prosty „chip” info
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });

  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: fg)),
        ],
      ),
    );
  }
}
