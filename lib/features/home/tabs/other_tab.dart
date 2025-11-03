import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/settings/settings_page.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart'; // ← nowy import


class OtherTab extends StatefulWidget {
  const OtherTab({
    super.key,
    required this.onLogout,
    required this.config,
  });

  final Future<void> Function() onLogout;
  final ApiConfig config;

  @override
  State<OtherTab> createState() => _OtherTabState();
}

class _OtherTabState extends State<OtherTab> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_showSettings) {
      return Column(
        children: [
          // Pasek powrotu "<- Ustawienia"
          Material(
            color: cs.surface,
            child: InkWell(
              onTap: () => setState(() => _showSettings = false),
              child: Container(
                height: 44,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '<- Ustawienia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: SettingsBody(config: widget.config)),
        ],
      );
    }

    // Lista opcji
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ArrowButton(
          title: 'Ustawienia',
          onTap: () => setState(() => _showSettings = true),
        ),
        const SizedBox(height: 12),
        ArrowButton(
          title: 'Wyloguj',
          onTap: () async {
            final navigator = Navigator.of(context);// bezpiecznie przed await
            await widget.onLogout();
            if (!mounted) return;
            navigator.pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            ); 
          },
        ),
      ],
    );
  }
}
