// lib/features/vehicles/pages/wpm_search_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_api.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart';

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
  String? _error;
  List<WpmVehicleDto> _rows = const [];

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
      _error = null;
      _rows = const [];
    });

    final res = await widget.vehiclesApi.searchWpm(
      nrRejestracyjny: nrRej.isEmpty ? null : nrRej,
      numerPodwozia: vin.isEmpty ? null : vin,
      nrSerProducenta: serProd.isEmpty ? null : serProd,
      nrSerSilnika: serSilnika.isEmpty ? null : serSilnika,
    );

    if (!mounted) return;

    if (res.isOk) {
      setState(() {
        _rows = res.value;
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WPM – wyszukiwanie pojazdu wojskowego'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nrRejCtrl,
              decoration: const InputDecoration(
                labelText: 'Nr rejestracyjny',
                prefixIcon: Icon(Icons.onetwothree),
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _vinCtrl,
              decoration: const InputDecoration(
                labelText: 'Numer podwozia (VIN)',
                prefixIcon: Icon(Icons.directions_car),
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _serProdCtrl,
              decoration: const InputDecoration(
                labelText: 'Nr ser. producenta',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _serSilnikaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nr ser. silnika',
                prefixIcon: Icon(Icons.settings_outlined),
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

            if (_error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),

            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),

            Expanded(
              child: _rows.isEmpty
                  ? const Center(child: Text('Brak wyników'))
                  : ListView.separated(
                      itemCount: _rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final row = _rows[i];
                        final subtitleParts = <String>[
                          if (row.opis.isNotEmpty) row.opis,
                          if (row.rokProdukcji != null) 'Rok: ${row.rokProdukcji}',
                        ];
                        final subtitle = subtitleParts.join(' • ');

                        final fallback = const JsonEncoder.withIndent('  ').convert({
                          'nrRejestracyjny': row.nrRejestracyjny,
                          'numerPodwozia': row.numerPodwozia,
                          'nrSerProducenta': row.nrSerProducenta,
                          'nrSerSilnika': row.nrSerSilnika,
                          'opis': row.opis,
                          'rokProdukcji': row.rokProdukcji,
                        });

                        return ListTile(
                          title: Text(
                            row.nrRejestracyjny.isEmpty ? 'Rekord #${i + 1}' : row.nrRejestracyjny,
                          ),
                          subtitle: subtitle.isEmpty ? Text(fallback) : Text(subtitle),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
