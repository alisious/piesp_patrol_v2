import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_config.dart';

/// Ekran ustawień jako osobna strona (Scaffold + AppBar).
/// Działa jak dotychczas, ale wewnątrz używa SettingsBody, żeby logika była wspólna.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.config});
  static const route = '/settings';
  final ApiConfig config;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: SettingsBody(config: config),
    );
  }
}

/// Ten widget renderuje **samą treść** ustawień (bez Scaffold/AppBar).
/// Dzięki temu można go wstawić "pomiędzy AppBar i NavBar"
/// bez dublowania nagłówków (np. w OtherTab).
class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key, required this.config});
  final ApiConfig config;

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  late final TextEditingController _urlCtrl =
      TextEditingController(text: widget.config.baseUrl);
  late final TextEditingController _pemCtrl =
      TextEditingController(text: widget.config.pemAssetPath);
  late final TextEditingController _hostsCtrl =
      TextEditingController(text: widget.config.allowedHosts.join(','));
  late final TextEditingController _pinsCtrl =
      TextEditingController(text: widget.config.pinnedSpki.join(','));

  late String _tlsMode = widget.config.tlsMode;
  bool _saved = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _pemCtrl.dispose();
    _hostsCtrl.dispose();
    _pinsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.config
      ..baseUrl = _urlCtrl.text.trim()
      ..tlsMode = _tlsMode
      ..pemAssetPath = _pemCtrl.text.trim()
      ..allowedHosts = _hostsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
      ..pinnedSpki = _pinsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

    await widget.config.save();
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    // Ten ListView można osadzić wszędzie – jako pełny ekran (przez SettingsPage)
    // albo jako treść między AppBar/NavBar (np. w OtherTab).
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Base URL
        TextField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            helperText: 'Np. https://portal.kacper.zw.int:3443',
            prefixIcon: Icon(Icons.http),
          ),
        ),
        const SizedBox(height: 16),

        // Zaawansowane TLS/CA
        ExpansionTile(
          leading: const Icon(Icons.tune),
          title: const Text(
            'Zaawansowane (TLS / CA)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            // Tryb TLS
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _tlsMode,
              items: const [
                DropdownMenuItem(
                  value: 'systemOnly',
                  child: Text(
                    'systemOnly (MDM + network_security_config)',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                DropdownMenuItem(
                  value: 'assetCa',
                  child: Text('assetCa (PEM w assets)'),
                ),
                DropdownMenuItem(
                  value: 'pinned',
                  child: Text('pinned (SPKI pinning)'),
                ),
              ],
              onChanged: (v) => setState(() => _tlsMode = v ?? _tlsMode),
              decoration: const InputDecoration(
                labelText: 'Tryb TLS',
                prefixIcon: Icon(Icons.https_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Ścieżka PEM (gdy assetCa)
            TextField(
              controller: _pemCtrl,
              decoration: const InputDecoration(
                labelText: 'Ścieżka PEM (asset)',
                helperText: 'Np. assets/certs/kacper_ca.pem',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Dozwolone hosty
            TextField(
              controller: _hostsCtrl,
              decoration: const InputDecoration(
                labelText: 'Dozwolone hosty',
                helperText: 'Lista rozdzielana przecinkami (np. api.kacper.zw.int, portal.kacper.zw.int)',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Piny SPKI
            TextField(
              controller: _pinsCtrl,
              decoration: const InputDecoration(
                labelText: 'Piny (SPKI/sha256)',
                helperText: 'Lista rozdzielana przecinkami (hex lub Base64 SPKI)',
                prefixIcon: Icon(Icons.fingerprint_outlined),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
        const SizedBox(height: 16),

        // Zapisz
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Zapisz'),
        ),

        if (_saved) ...[
          const SizedBox(height: 8),
          Text(
            'Zapisano. Zmiany działają od razu.',
            style: TextStyle(color: Colors.green.withValues(alpha: 0.9)),
          ),
        ],
      ],
    );
  }
}
