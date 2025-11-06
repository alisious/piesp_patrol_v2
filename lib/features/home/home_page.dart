import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';

// Zakładki:
import 'package:piesp_patrol/features/home/tabs/duty_tab.dart';
import 'package:piesp_patrol/features/home/tabs/services_tab.dart';
import 'package:piesp_patrol/features/home/tabs/other_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
 
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0; // domyślnie: Służba

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authController = AppScope.of(context).authController as AuthController;
    final me = authController.meProfile; // pełny profil z /piesp/Auth/me

    final badge = me?.badgeNumber ?? '—';
    final name  = me?.userName ?? 'Nie zalogowano';

    final (title, icon) = _titleAndIconFor(_index);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 0.8, // ~20% niższy AppBar
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(icon, size: 20, color: cs.onPrimaryContainer), // było 22
          const SizedBox(width: 6), // było 8
          Text(title, style: TextStyle(color: cs.onPrimaryContainer)),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);//bezpiecznie przed await
              final auth = AppScope.of(context).authController as AuthController;
              await auth.logout();
              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil(AppRoutes.login,(route) => false); 
            },
          ),
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
          const SizedBox(width: 10), // było 12
          Expanded(
            child: _InfoChip(
              bg: cs.surfaceContainerHighest,
              fg: cs.onSurface,
              icon: Icons.account_circle_outlined,
              label: name,
            ),
          ),
          const SizedBox(width: 10), // było 12
          _IconOnlyChip(
            bg: cs.surfaceContainerHighest,
            fg: cs.onSurfaceVariant,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    ),
  ),
),

      body: IndexedStack(
        index: _index,
        children: [
          DutyTab(unitName: me?.unitName),
          ServicesTab(),
          OtherTab(),
        ],
      ),

      bottomNavigationBar: Theme(
  data: Theme.of(context).copyWith(
    navigationBarTheme: NavigationBarThemeData(
      height: 52, // było domyślnie ~80; kompaktowy pasek
      backgroundColor: cs.surfaceContainerHigh,
      indicatorColor: cs.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
        (states) => IconThemeData(
          size: 20, // mniejsze ikony
          color: states.contains(WidgetState.selected)
              ? cs.onPrimaryContainer
              : cs.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (states) => TextStyle(
          fontSize: 11, // mniejsza czcionka etykiet
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? cs.onPrimaryContainer
              : cs.onSurfaceVariant,
        ),
      ),
    ),
  ),
  child: NavigationBar(
    selectedIndex: _index,
    onDestinationSelected: (i) => setState(() => _index = i),
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.shield_moon_outlined),
        selectedIcon: Icon(Icons.shield_moon),
        label: 'Służba',
      ),
      NavigationDestination(
        icon: Icon(Icons.edit_document),
        selectedIcon: Icon(Icons.edit_document),
        label: 'Usługi',
      ),
      NavigationDestination(
        icon: Icon(Icons.more_horiz),
        selectedIcon: Icon(Icons.more_horiz),
        label: 'Inne',
      ),
    ],
  ),
),

    );
  }

  (String, IconData) _titleAndIconFor(int i) {
    switch (i) {
      case 0:
        return ('Służba', Icons.shield_moon);
      case 1:
        return ('Usługi', Icons.edit_document);
      default:
        return ('Inne', Icons.more_horiz);
    }
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

class _IconOnlyChip extends StatelessWidget {
  const _IconOnlyChip({required this.bg, required this.fg, required this.icon});
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}