// lib/features/cep/pages/vehicle_question_extended_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/cep/data/cep_api.dart';
import 'package:piesp_patrol/features/cep/data/cep_dictionary_service.dart';
import 'package:piesp_patrol/features/cep/data/cep_pojazd_dtos.dart';
import 'package:piesp_patrol/features/cep/data/cep_slowniki_dtos.dart';
import 'package:piesp_patrol/widgets/dropdown_box.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/common_params.dart';
import 'package:piesp_patrol/widgets/button_search.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';

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
  CepVehicleDocTypeLite ? _selectedDocType; 
  final String _defaultDocTypeCode = 'DICT155_DR' ; // "Dowód rejestracyjny"
 
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
      // ewentualne czyszczenie stanu ładowania itp.
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: const CommonAppBar(
      title: 'Sprawdź pojazd',
      showBack: true,
    ),
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
              DropdownBox<CepVehicleDocTypeLite>(
                label: 'Typ dokumentu',
                items: _docTypes,
                itemLabel: (e) => e.wartoscOpisowa!,
                value: _selectedDocType,
                onChanged: (v) => setState(() => _selectedDocType = v),
                hint: 'Wybierz typ dokumentu',
                borderStyle: InputBorderStyle.underline,
                allowClear: true,
              ),
             
              const SizedBox(height: 12),

              // dokumentSeriaNumer
              InputBox(
               controller: _dokumentSeriaNumerCtrl,
               label: 'Seria i numer dokumentu',
               preset: InputPreset.text,
               uppercase: true,
               maxLength: 50,
              ),
              const SizedBox(height: 12),

              // numerRejestracyjny
               InputBox(
               controller: _nrRejCtrl,
               label: 'Numer rejestracyjny (PL)',
               preset: InputPreset.text,
               uppercase: true,
               maxLength: 50,
              ),
              const SizedBox(height: 12),

              // numerRejestracyjnyZagraniczny
              InputBox(
               controller: _nrRejZagrCtrl,
               label: 'Numer rejestracyjny (zagraniczny)',
               preset: InputPreset.text,
               uppercase: true,
               maxLength: 50,
              ),
              const SizedBox(height: 12),

              // VIN
              InputBox(
               controller: _vinCtrl,
               label: 'Numer podwozia/nadwozia/ramy (VIN)',
               preset: InputPreset.text,
               uppercase: true,
               maxLength: 60,
              ),

              const SizedBox(height: 20),

              ButtonSearch(
                onPressedAsync: () async {
                // tu Twoja logika: walidacja + wywołanie API
                // final valid = _formKey.currentState?.validate() ?? false;
                // if (!valid) throw Exception('Uzupełnij wymagane pola.');
                 await _onSearch();
                },
                enabled: true,        // np. (_formKey.currentState?.validate() ?? false)
                fullWidth: true,      // albo false, jeśli w Row obok innych przycisków
                label: 'Wyszukaj',
                icon: Icons.search,    // opcjonalnie: Icons.manage_search
                // showErrorSnackBar: false, // jeśli chcesz obsłużyć błędy sam
                // errorToMessage: (e) => mapuj sobie wyjątek na ładny komunikat,
              ),

              
            ],
          ),
        ),
      ),
    );
  }

  String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
