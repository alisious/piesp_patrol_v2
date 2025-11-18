import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piesp_patrol/core/api_config.dart';

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

  // OBSŁUGIWANE TRYBY TLS
  static const Set<String> _allowedTlsModes = {
    'systemOnly',
    'assetCa',
    'pinned',
    'systemThenAssetFallback',
  };

  late String _tlsMode = widget.config.tlsMode;
  bool _saved = false;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    // Normalizacja wartości spoza listy (na wypadek starych zapisów)
    if (!_allowedTlsModes.contains(_tlsMode)) {
      _tlsMode = 'systemOnly';
    }
    // Pobierz informacje o wersji aplikacji
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
      });
    }
  }

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

  bool get _needsPem =>
      _tlsMode == 'assetCa' || _tlsMode == 'systemThenAssetFallback';

  @override
  Widget build(BuildContext context) {
    

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
                  child: Text('systemOnly (MDM + network_security_config)'),
                ),
                DropdownMenuItem(
                  value: 'assetCa',
                  child: Text('assetCa (PEM w assets)'),
                ),
                DropdownMenuItem(
                  value: 'pinned',
                  child: Text('pinned (SPKI pinning)'),
                ),
                DropdownMenuItem(
                  value: 'systemThenAssetFallback',
                  child: Text('systemThenAssetFallback (najpierw system, potem asset)'),
                ),
              ],
              onChanged: (v) => setState(() => _tlsMode = v ?? _tlsMode),
              decoration: const InputDecoration(
                labelText: 'Tryb TLS',
                prefixIcon: Icon(Icons.https_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Ścieżka PEM – wymagane dla assetCa i systemThenAssetFallback
            if (_needsPem) ...[
              TextField(
                controller: _pemCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ścieżka PEM (asset)',
                  helperText: 'Np. assets/certs/kacper_ca.pem',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Dozwolone hosty
            TextField(
              controller: _hostsCtrl,
              decoration: const InputDecoration(
                labelText: 'Dozwolone hosty',
                helperText:
                    'Lista rozdzielana przecinkami (np. api.kacper.zw.int, portal.kacper.zw.int)',
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
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        
        // Informacje o wersji aplikacji
        if (_packageInfo != null)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wersja aplikacji',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _packageInfo!.buildNumber.isNotEmpty
                          ? '${_packageInfo!.version} (build ${_packageInfo!.buildNumber})'
                          : _packageInfo!.version,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Ładowanie informacji o wersji...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
