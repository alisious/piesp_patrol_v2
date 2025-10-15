import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/settings/settings_page.dart';


class HomePage extends StatelessWidget {
const HomePage({super.key, required this.auth, required this.config});
final AuthController auth;
final ApiConfig config;


@override
Widget build(BuildContext context) {
final p = auth.profile;
return Scaffold(
appBar: AppBar(
title: const Text('Strona domowa'),
actions: [
IconButton(
tooltip: 'Ustawienia',
onPressed: () => Navigator.pushNamed(context, SettingsPage.route),
icon: const Icon(Icons.settings),
),
IconButton(
tooltip: 'Wyloguj',
onPressed: () async {
await auth.logout();
if (context.mounted) {
Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}
},
icon: const Icon(Icons.logout),
),
],
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.shield_moon_outlined, size: 64),
const SizedBox(height: 16),
Text(p != null ? 'Witaj, ${p.badgeNumber} ${p.unitName!=null ? '${p.unitName}' : ''}' : 'Witaj!'),
const SizedBox(height: 8),
Text('Endpoint: ${config.baseUrl}', style: const TextStyle(fontSize: 12)),
],
),
),
);
}
}
