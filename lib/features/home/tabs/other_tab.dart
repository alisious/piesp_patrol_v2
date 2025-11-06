import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
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
 
  @override
  Widget build(BuildContext context) {
   
    // Lista opcji
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ArrowButton(
          title: 'Ustawienia',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settingsPage),
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
