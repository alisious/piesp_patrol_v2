import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.config});
  static const route = '/settings';
  final ApiConfig config;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia API')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              helperText: 'Np. https://portal.kacper.zw.int:3443',
              prefixIcon: Icon(Icons.http),
            ),
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            leading: const Icon(Icons.tune),
            title: const Text(
              'Zaawansowane (TLS / CA)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _tlsMode,
                items: const [
                  DropdownMenuItem(
                    value: 'systemOnly',
                    child: Text('systemOnly (MDM + network_security_config)',
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
                    value: 'pinOnly',
                    child: Text('pinOnly (SPKI/sha256)'),
                  ),
                  DropdownMenuItem(
                    value: 'assetCaAndPin',
                    child: Text('assetCa + pinning'),
                  ),
                  DropdownMenuItem(
                    value: 'systemThenAssetFallback',
                    child: Text('systemThenAssetFallback (DEV/QA)'),
                  ),
                ],
                onChanged: (v) => setState(() => _tlsMode = v ?? 'systemOnly'),
                decoration: const InputDecoration(labelText: 'Tryb TLS'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pemCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ścieżka PEM (asset)',
                  helperText: 'Np. assets/certs/kacper_ca.pem',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hostsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hosty objęte polityką',
                  helperText:
                      'Lista rozdzielana przecinkami, np. portal.kacper.zw.int',
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
              ),
              const SizedBox(height: 12),
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
          ]
        ],
      ),
    );
  }
}
