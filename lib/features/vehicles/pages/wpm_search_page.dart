// lib/features/vehicles/pages/wpm_search_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_api.dart';
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_result_page.dart';

class WpmSearchPage extends StatefulWidget {
  const WpmSearchPage({super.key, required this.vehiclesApi});
  final VehiclesApi vehiclesApi;

  @override
  State<WpmSearchPage> createState() => _WpmSearchPageState();
}

class _WpmSearchPageState extends State<WpmSearchPage> {
  final _nrRejCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _serProdCtrl = TextEditingController();
  final _serSilnikaCtrl = TextEditingController();

  bool _loading = false;
  
  @override
  void dispose() {
    _nrRejCtrl.dispose();
    _vinCtrl.dispose();
    _serProdCtrl.dispose();
    _serSilnikaCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final nrRej = _nrRejCtrl.text.trim();
    final vin = _vinCtrl.text.trim();
    final serProd = _serProdCtrl.text.trim();
    final serSilnika = _serSilnikaCtrl.text.trim();

    setState(() {
      _loading = true;
    });

    final res = await widget.vehiclesApi.searchWpm(
      nrRejestracyjny: nrRej.isEmpty ? null : nrRej,
      numerPodwozia: vin.isEmpty ? null : vin,
      nrSerProducenta: serProd.isEmpty ? null : serProd,
      nrSerSilnika: serSilnika.isEmpty ? null : serSilnika,
    );

 if (res.isOk) {
  final rows = res.value;
  setState(() => _loading = false);
  if (!mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => WpmSearchResultPage(rows: rows)),
  );
} else {
  setState(() => _loading = false);
  _showSnack(res.error.message.isNotEmpty
      ? res.error.message
      : 'Wystąpił błąd podczas wyszukiwania.');
}

  }

  void _showSnack(String message) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(
      SnackBar(content: Text(message)),
    );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprawdź pojazd wojskowy'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Podaj przynajmniej jedno kryterium wyszukiwania.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _nrRejCtrl,
              decoration: const InputDecoration(
                labelText: 'Nr rejestracyjny',
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _vinCtrl,
              decoration: const InputDecoration(
                labelText: 'Numer podwozia (VIN)',
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _serProdCtrl,
              decoration: const InputDecoration(
                labelText: 'Nr ser. producenta',
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _serSilnikaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nr ser. silnika',
              ),
              onSubmitted: (_) => _loading ? null : _search(),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Szukaj'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
           
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            ],
        ),
      ),
    );
  }
  
}
