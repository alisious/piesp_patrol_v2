// lib/features/vehicles/pages/wpm_search_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_api.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class WpmSearchPage extends StatefulWidget {
  const WpmSearchPage({super.key});
  

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

  void _showSnack(String message) {
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();

    final nrRej = _nrRejCtrl.text.trim();
    final vin = _vinCtrl.text.trim();
    final serProd = _serProdCtrl.text.trim();
    final serSilnika = _serSilnikaCtrl.text.trim();

    if (nrRej.isEmpty && vin.isEmpty && serProd.isEmpty && serSilnika.isEmpty) {
      _showSnack('Podaj przynajmniej jedno kryterium wyszukiwania.');
      return;
    }

    setState(() => _loading = true);
    try {
      // ⬇⬇⬇ WYWOŁANIE I NAZWY PARAMETRÓW — BEZ ZMIAN ⬇⬇⬇
      final VehiclesApi vehiclesApi = AppScope.of(context).vehiclesApi as VehiclesApi;
      final res = await vehiclesApi.searchWpm(
        nrRejestracyjny: nrRej.isEmpty ? null : nrRej,
        numerPodwozia: vin.isEmpty ? null : vin,
        nrSerProducenta: serProd.isEmpty ? null : serProd,
        nrSerSilnika: serSilnika.isEmpty ? null : serSilnika,
      );

      if (!mounted) return;

      if (res.isOk) {
        final rows = res.value;
        setState(() => _loading = false);
        await Navigator.pushNamed(
          context, 
          AppRoutes.wpmSearchResults,
          arguments: WpmVehicleArgs(wpmList: rows),
        ); 
      } else {
        setState(() => _loading = false);
        _showSnack(
          res.error.message.isNotEmpty
              ? res.error.message
              : 'Wystąpił błąd podczas wyszukiwania.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Błąd wyszukiwania: $e');
    }
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
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: 720, // ograniczenie szerokości dla WEB
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 12),

              // Zwężenie samych pól formularza dla lepszego wyglądu w przeglądarce
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    TextField(
                      controller: _nrRejCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nr rejestracyjny',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vinCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Numer podwozia (VIN)',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _serProdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nr ser. producenta',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _serSilnikaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nr ser. silnika',
                      ),
                      onSubmitted: (_) => _loading ? null : _search(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Szukaj'),
              ),
              const SizedBox(height: 12),

              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
