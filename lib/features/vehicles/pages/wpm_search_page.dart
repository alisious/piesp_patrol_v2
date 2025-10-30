// lib/features/vehicles/pages/wpm_search_page.dart
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                child: Text(
                  _error!,
                  style: TextStyle(color: cs.error),
                ),
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
                        final items = _dtoNonNullKvp(row);

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: cs.surface,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: cs.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tytuł: nr rejestracyjny lub opisowy fallback
                                Text(
                                  row.nrRejestracyjny?.isNotEmpty == true
                                      ? 'Nr rej: ${row.nrRejestracyjny!}'
                                      : 'Rekord #${i + 1}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Reszta atrybutów jako lista label: value (tylko nie-null)
                                ...items.map((kv) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: _kvLine(
                                        context,
                                        kv.$1, // label
                                        kv.$2, // value
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tworzy listę (label, value) dla wszystkich atrybutów nie-null/nie-pustych.
  List<(String, String)> _dtoNonNullKvp(WpmVehicleDto d) {
    String? s(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    String? i(int? v) => v?.toString();

    final kv = <(String, String)>[];

    void add(String label, String? value) {
      final v = s(value);
      if (v != null) kv.add((label, v));
    }

    void addInt(String label, int? value) {
      final v = i(value);
      if (v != null) kv.add((label, v));
    }

    // Uporządkowana prezentacja wszystkich pól DTO:
    //addInt('ID', d.id);
    //add('Nr rejestracyjny', d.nrRejestracyjny);
    add('Opis', d.opis);
    addInt('Rok produkcji', d.rokProdukcji);
    add('Numer podwozia (VIN)', d.numerPodwozia);
    add('Nr ser. producenta', d.nrSerProducenta);
    add('Nr ser. silnika', d.nrSerSilnika);
    add('Miejscowość', d.miejscowosc);
    add('Jednostka wojskowa', d.jednostkaWojskowa);
    add('Jednostka gospodarcza', d.jednostkaGospodarcza);
    add('Data aktualizacji', d.dataAktualizacji);

    return kv;
  }

  Widget _kvLine(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Expanded(
          flex: 5,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        // value
        Expanded(
          flex: 7,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
