// lib/features/cep/pages/vehicle_question_extended_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/cep/data/cep_api.dart';
import 'package:piesp_patrol/features/cep/data/cep_dictionary_service.dart';
import 'package:piesp_patrol/features/cep/data/cep_pojazd_dtos.dart';
import 'package:piesp_patrol/features/cep/data/cep_slowniki_dtos.dart';

class VehicleQuestionExtendedPage extends StatefulWidget {
  const VehicleQuestionExtendedPage({super.key});

  @override
  State<VehicleQuestionExtendedPage> createState() => _VehicleQuestionExtendedPageState();
}

class _VehicleQuestionExtendedPageState extends State<VehicleQuestionExtendedPage> {
  final _dokumentSeriaNumerCtrl = TextEditingController();
  final _nrRejCtrl = TextEditingController();
  final _nrRejZagrCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();

  String? _typDokumentu; // kod słownikowy
  final String _defaultDocTypeCode = 'DICT155_DR' ; // "Dowód rejestracyjny"
  bool _loading = false;
  bool _depsInit = false;
  List<CepVehicleDocTypeLite> _docTypes = const [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_depsInit) {
      _depsInit = true;
      _loadDocTypes(); // <--- TERAZ bezpiecznie, mamy już zależności Inherited
    }
  }

  @override
  void dispose() {
    _dokumentSeriaNumerCtrl.dispose();
    _nrRejCtrl.dispose();
    _nrRejZagrCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDocTypes() async {
    final cepDisctionaryService = AppScope.of(context).cepDictionaryService as CepDictionaryService;
    final resp = await cepDisctionaryService.getVehicleDocumentTypesLocal();
    if (!mounted) return;

    setState(() {
      _docTypes = resp;
      // domyślnie wybierz DICT155_DR (jeśli istnieje w słowniku),
     // w przeciwnym razie pierwszy dostępny wpis
      _typDokumentu ??= resp.any((e) => e.kod == _defaultDocTypeCode)
          ? _defaultDocTypeCode
          : (resp.isNotEmpty ? resp.first.kod : null); 
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(message)));
  }

  CepPytanieOPojazdRequest _buildRequest() {
    return CepPytanieOPojazdRequest(
      typDokumentu: _typDokumentu,
      dokumentSeriaNumer: _nullIfEmpty(_dokumentSeriaNumerCtrl.text),
      numerRejestracyjny: _nullIfEmpty(_nrRejCtrl.text),
      numerRejestracyjnyZagraniczny: _nullIfEmpty(_nrRejZagrCtrl.text),
      numerPodwoziaNadwoziaRamy: _nullIfEmpty(_vinCtrl.text),
      // Możesz dodać dataPrezentacji / wyszukiwaniePoDanychHistorycznych później
    );
  }

  Future<void> _onSearch() async {
    setState(() => _loading = true);
    try {
      final cepApi = AppScope.of(context).cepApi as CepApi;
      final req = _buildRequest();

      final localErr = req.validateMinimalCriteria();
      if (localErr != null) {
        _showSnack(localErr);
        return;
      }

      final resp = await cepApi.vehicleQuestionExtended(req);
      if (!mounted) return;

      final status = resp.status ?? -1;
      final msg = (resp.message?.isNotEmpty ?? false)
          ? resp.message!
          : (status == 0
              ? 'Zapytanie wykonane.'
              : 'Błąd zapytania.');

      _showSnack(
        status == 0
            ? 'OK: $msg'
            : 'Błąd ($status): $msg',
      );

      // Tu ewentualnie: nawigacja do strony wynikowej, gdy dodasz widok szczegółów pojazdu.
      // if (status == 0 && resp.data?.pojazdRozszerzone != null) { ... }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ddItems = _docTypes
        .map((e) => DropdownMenuItem<String>(
              value: e.kod,
              child: Text('${e.wartoscOpisowa}'),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sprawdź pojazd')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wprowadź kryteria (wymagania minimalne):\n'
                '• typDokumentu i dokumentSeriaNumer LUB\n'
                '• numerRejestracyjny LUB\n'
                '• numerRejestracyjnyZagraniczny LUB\n'
                '• VIN (nie łączyć z innymi).',
              ),
              const SizedBox(height: 16),

              // typDokumentu
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Typ dokumentu',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _typDokumentu,
                    isExpanded: true,
                    items: ddItems,
                    onChanged: (v) => setState(() => _typDokumentu = v),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // dokumentSeriaNumer
              TextField(
                controller: _dokumentSeriaNumerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dokument – seria i numer',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9/-]'))],
              ),
              const SizedBox(height: 12),

              // numerRejestracyjny
              TextField(
                controller: _nrRejCtrl,
                decoration: const InputDecoration(
                  labelText: 'Numer rejestracyjny (PL)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
              ),
              const SizedBox(height: 12),

              // numerRejestracyjnyZagraniczny
              TextField(
                controller: _nrRejZagrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Numer rejestracyjny (zagraniczny)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
              ),
              const SizedBox(height: 12),

              // VIN
              TextField(
                controller: _vinCtrl,
                decoration: const InputDecoration(
                  labelText: 'Numer podwozia/nadwozia/ramy (VIN)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _onSearch,
                  icon: _loading
                      ? const SizedBox(
                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: const Text('Wyszukaj'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
