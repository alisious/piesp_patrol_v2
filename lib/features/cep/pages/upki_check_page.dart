// lib/features/cep/pages/upki_check_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/cep/data/cep_api.dart';
import 'package:piesp_patrol/features/cep/data/upki_dtos.dart';
import 'package:piesp_patrol/features/srp/data/person_controller.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/button_search.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class UpKiCheckPage extends StatefulWidget {
  const UpKiCheckPage({super.key});

  @override
  State<UpKiCheckPage> createState() => _UpKiCheckPageState();
}

class _UpKiCheckPageState extends State<UpKiCheckPage> {
  // Selection: PESEL, Person data, Numer dokumentu (uprawnienia), or Seria numer dokumentu (blankiet)
  String _searchType = 'pesel';

  // PESEL fields
  final _peselCtrl = TextEditingController();

  // Person fields
  final _imieCtrl = TextEditingController();
  final _nazwiskoCtrl = TextEditingController();
  final _dataUrodzeniaCtrl = TextEditingController();

  // Document fields
  final _numerDokumentuCtrl = TextEditingController();
  final _seriaNumerDokumentuCtrl = TextEditingController();

  @override
  void dispose() {
    _peselCtrl.dispose();
    _imieCtrl.dispose();
    _nazwiskoCtrl.dispose();
    _dataUrodzeniaCtrl.dispose();
    _numerDokumentuCtrl.dispose();
    _seriaNumerDokumentuCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Wypełnia pola formularza danymi z wybranej osoby.
  void _fillFieldsFromSelectedPerson() {
    final personController = AppScope.of(context).personController as PersonController;
    final selectedPerson = personController.selectedPerson;
    
    if (selectedPerson == null) {
      _showSnack('Brak wybranej osoby.');
      return;
    }

    setState(() {
      if (_searchType == 'pesel') {
        // Wypełnij pole PESEL
        _peselCtrl.text = selectedPerson.pesel ?? '';
      } else if (_searchType == 'daneOsoby') {
        // Wypełnij pola: Imię pierwsze, Nazwisko, Data urodzenia
        _imieCtrl.text = selectedPerson.imie ?? '';
        _nazwiskoCtrl.text = selectedPerson.nazwisko ?? '';
        
        // Konwertuj datę urodzenia z formatu yyyyMMdd na yyyy-MM-dd jeśli potrzeba
        final dataUrodzenia = selectedPerson.dataUrodzenia ?? '';
        if (dataUrodzenia.isNotEmpty) {
          // Jeśli data jest w formacie yyyyMMdd (8 znaków), konwertuj na yyyy-MM-dd
          if (dataUrodzenia.length == 8 && RegExp(r'^\d{8}$').hasMatch(dataUrodzenia)) {
            _dataUrodzeniaCtrl.text = '${dataUrodzenia.substring(0, 4)}-${dataUrodzenia.substring(4, 6)}-${dataUrodzenia.substring(6, 8)}';
          } else {
            // W przeciwnym razie użyj oryginalnej wartości (może być już w formacie yyyy-MM-dd)
            _dataUrodzeniaCtrl.text = dataUrodzenia;
          }
        } else {
          _dataUrodzeniaCtrl.text = '';
        }
      }
      // Dla numerDokumentu i seriaNumerDokumentu nie ma danych w personController
    });
    
    _showSnack('Wypełniono pola danymi wybranej osoby.');
  }

  UpKiRequest _buildRequest() {
    // Tworzenie requestu z wszystkimi polami (zostaną przesłane tylko wypełnione)
    final peselText = _peselCtrl.text.trim();
    final numerPesel = peselText.isNotEmpty ? peselText : null;
    
    final daneOsoby = (_searchType == 'daneOsoby' &&
            (_imieCtrl.text.trim().isNotEmpty ||
             _nazwiskoCtrl.text.trim().isNotEmpty ||
             _dataUrodzeniaCtrl.text.trim().isNotEmpty))
        ? UpKiDaneOsoby(
            imiePierwsze: _nullIfEmpty(_imieCtrl.text),
            nazwisko: _nullIfEmpty(_nazwiskoCtrl.text),
            dataUrodzenia: _nullIfEmpty(_dataUrodzeniaCtrl.text),
          )
        : null;
    
    final numerDokumentu = _nullIfEmpty(_numerDokumentuCtrl.text);
    final seriaNumerDokumentu = _nullIfEmpty(_seriaNumerDokumentuCtrl.text);
    
    return UpKiRequest(
      dataZapytania: null, // Nie ustawiamy automatycznie - użytkownik musi ustawić jawnie
      numerPesel: numerPesel,
      numerDokumentu: numerDokumentu,
      seriaNumerDokumentu: seriaNumerDokumentu,
      daneOsoby: daneOsoby,
    );
  }

  Future<void> _onSearch() async {
    try {
      final cepApi = AppScope.of(context).cepApi as CepApi;
      final req = _buildRequest();

      final localErr = req.validate();
      if (localErr != null) {
        _showSnack(localErr);
        return;
      }

      final resp = await cepApi.uprawnieniaKierowcy(req);
      if (!mounted) return;

      final status = resp.status ?? -1;
      final msg = (resp.message?.isNotEmpty ?? false)
          ? resp.message!
          : (status == 0
              ? 'Zapytanie wykonane.'
              : 'Błąd zapytania.');

      if (status == 0 && resp.data != null) {
        // Nawigacja do strony wyników
        final navigator = Navigator.of(context);
        navigator.pushNamed(
          AppRoutes.upkiCheckResultPage,
          arguments: UpKiCheckResultArgs(response: resp.data!),
        );
      } else {
        _showSnack(
          status == 0
              ? 'OK: $msg'
              : 'Błąd ($status): $msg',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Wyjątek: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Sprawdź uprawnienia kierowcy',
        showBack: true,
      ),
      body: PageContainer(
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wybierz sposób wyszukiwania:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final personController = AppScope.of(context).personController as PersonController;
                    return Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(
                                value: 'pesel',
                                label: Text(
                                  'PESEL',
                                  style: TextStyle(fontSize: Theme.of(context).textTheme.labelLarge?.fontSize != null
                                      ? Theme.of(context).textTheme.labelLarge!.fontSize! * 0.5
                                      : null),
                                ),
                              ),
                              ButtonSegment<String>(
                                value: 'daneOsoby',
                                tooltip: 'Dane osoby',
                                icon: const Icon(Icons.person),
                              ),
                              ButtonSegment<String>(
                                value: 'numerDokumentu',
                                tooltip: 'Numer dokumentu (uprawnienia)',
                                icon: const Icon(Icons.description),
                              ),
                              ButtonSegment<String>(
                                value: 'seriaNumerDokumentu',
                                tooltip: 'Seria i numer dokumentu (blankiet)',
                                icon: const Icon(Icons.credit_card),
                              ),
                            ],
                            selected: {_searchType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _searchType = newSelection.first;
                              });
                            },
                          ),
                        ),
                        AnimatedBuilder(
                          animation: personController,
                          builder: (context, _) {
                            final hasSelectedPerson = personController.selectedPerson != null;
                            
                            if (hasSelectedPerson) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Tooltip(
                                  message: 'Wypełnij pola danymi wybranej osoby',
                                  child: InkWell(
                                    onTap: _fillFieldsFromSelectedPerson,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.person,
                                        color: (personController.selectedPerson?.czyPoszukiwana == true)
                                            ? Theme.of(context).colorScheme.error
                                            : Theme.of(context).colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                if (_searchType == 'pesel') ...[
                  // PESEL fields
                  InputBox(
                    controller: _peselCtrl,
                    label: 'PESEL',
                    preset: InputPreset.pesel,
                  ),
                ] else if (_searchType == 'daneOsoby') ...[
                  // Person fields
                  InputBox(
                    controller: _imieCtrl,
                    label: 'Imię pierwsze',
                    preset: InputPreset.text,
                    uppercase: true,
                  ),
                  const SizedBox(height: 12),
                  InputBox(
                    controller: _nazwiskoCtrl,
                    label: 'Nazwisko',
                    preset: InputPreset.text,
                    uppercase: true,
                  ),
                  const SizedBox(height: 12),
                  InputBox(
                    controller: _dataUrodzeniaCtrl,
                    label: 'Data urodzenia',
                    hint: 'RRRR-MM-DD',
                    preset: InputPreset.dateYmd,
                  ),
                ] else if (_searchType == 'numerDokumentu') ...[
                  // Numer dokumentu (uprawnienia) fields
                  InputBox(
                    controller: _numerDokumentuCtrl,
                    label: 'Numer dokumentu (uprawnienia)',
                    preset: InputPreset.text,
                  ),
                ] else if (_searchType == 'seriaNumerDokumentu') ...[
                  // Seria numer dokumentu (blankiet) fields
                  InputBox(
                    controller: _seriaNumerDokumentuCtrl,
                    label: 'Seria i numer dokumentu (blankiet)',
                    preset: InputPreset.text,
                  ),
                ],

                const SizedBox(height: 20),

                ButtonSearch(
                  onPressedAsync: () async {
                    await _onSearch();
                  },
                  enabled: true,
                  fullWidth: true,
                  label: 'Sprawdź uprawnienia',
                  icon: Icons.search,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

