// lib/features/ksip/pages/ksip_check_person_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/ksip/data/ksip_api.dart';
import 'package:piesp_patrol/features/ksip/data/ksip_sprawdzenie_osoby_dtos.dart';
import 'package:piesp_patrol/features/srp/data/person_controller.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/button_search.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class KsipCheckPersonPage extends StatefulWidget {
  const KsipCheckPersonPage({super.key});

  @override
  State<KsipCheckPersonPage> createState() => _KsipCheckPersonPageState();
}

class _KsipCheckPersonPageState extends State<KsipCheckPersonPage> {
  // Selection: PESEL or Person data
  String _searchType = 'pesel';

  // PESEL field
  final _peselCtrl = TextEditingController();

  // Person fields
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();

  @override
  void dispose() {
    _peselCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthDateCtrl.dispose();
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
        // Wypełnij pola: Imię, Nazwisko, Data urodzenia
        _firstNameCtrl.text = selectedPerson.imie ?? '';
        _lastNameCtrl.text = selectedPerson.nazwisko ?? '';
        
        // Konwertuj datę urodzenia z formatu yyyyMMdd na yyyy-MM-dd jeśli potrzeba
        final dataUrodzenia = selectedPerson.dataUrodzenia ?? '';
        if (dataUrodzenia.isNotEmpty) {
          // Jeśli data jest w formacie yyyyMMdd (8 znaków), konwertuj na yyyy-MM-dd
          if (dataUrodzenia.length == 8 && RegExp(r'^\d{8}$').hasMatch(dataUrodzenia)) {
            _birthDateCtrl.text = '${dataUrodzenia.substring(0, 4)}-${dataUrodzenia.substring(4, 6)}-${dataUrodzenia.substring(6, 8)}';
          } else {
            // W przeciwnym razie użyj oryginalnej wartości (może być już w formacie yyyy-MM-dd)
            _birthDateCtrl.text = dataUrodzenia;
          }
        } else {
          _birthDateCtrl.text = '';
        }
      }
    });
    
    _showSnack('Wypełniono pola danymi wybranej osoby.');
  }

  String? _validateRequest() {
    if (_searchType == 'pesel') {
      final peselText = _peselCtrl.text.trim();
      if (peselText.isEmpty) {
        return 'Podaj numer PESEL.';
      }
      if (peselText.length != 11) {
        return 'PESEL musi mieć 11 cyfr.';
      }
      return null;
    } else {
      // daneOsoby - wszystkie pola są wymagane
      final firstName = _firstNameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final birthDate = _birthDateCtrl.text.trim();

      if (firstName.isEmpty) {
        return 'Podaj imię.';
      }
      if (lastName.isEmpty) {
        return 'Podaj nazwisko.';
      }
      if (birthDate.isEmpty) {
        return 'Podaj datę urodzenia.';
      }

      // Sprawdź format daty
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate)) {
        return 'Format daty urodzenia: RRRR-MM-DD';
      }

      return null;
    }
  }

  KsipSprawdzenieOsobyRequestDto _buildRequest() {
    final auth = AppScope.of(context).authController as AuthController;
    final userId = auth.meProfile?.ksipUserId;

    final peselText = _searchType == 'pesel' ? _peselCtrl.text.trim() : null;
    final firstName = _searchType == 'daneOsoby' ? _nullIfEmpty(_firstNameCtrl.text) : null;
    final lastName = _searchType == 'daneOsoby' ? _nullIfEmpty(_lastNameCtrl.text) : null;
    final birthDate = _searchType == 'daneOsoby' ? _nullIfEmpty(_birthDateCtrl.text) : null;

    return KsipSprawdzenieOsobyRequestDto(
      userId: userId,
      nrPesel: _nullIfEmpty(peselText),
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      terminalName: null, // Możemy dodać później, jeśli będzie potrzebne
    );
  }

  Future<void> _onSearch() async {
    final validationError = _validateRequest();
    if (validationError != null) {
      _showSnack(validationError);
      return;
    }

    try {
      final scope = AppScope.of(context);
      final ksipApi = scope.ksipApi as KsipApi;
      final req = _buildRequest();

      final resp = await ksipApi.sprawdzenieOsobyWRuchuDrogowym(req);
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
          AppRoutes.ksipCheckPersonResultPage,
          arguments: KsipCheckPersonResultArgs(response: resp.data!),
        );
      } else {
        // Status 2 (błąd biznesowy) - wyświetl tylko message bez prefiksu "Błąd"
        if (status == 2) {
          _showSnack(msg);
        } else if (status == 0) {
          _showSnack('OK: $msg');
        } else {
          _showSnack('Błąd ($status): $msg');
        }
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
        title: 'Sprawdź osobę w ruchu drogowym',
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
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize != null
                                        ? Theme.of(context).textTheme.labelLarge!.fontSize! * 0.5
                                        : null,
                                  ),
                                ),
                              ),
                              ButtonSegment<String>(
                                value: 'daneOsoby',
                                tooltip: 'Dane osoby',
                                icon: const Icon(Icons.person),
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
                  // PESEL field
                  InputBox(
                    controller: _peselCtrl,
                    label: 'PESEL',
                    preset: InputPreset.pesel,
                  ),
                ] else if (_searchType == 'daneOsoby') ...[
                  // Person fields
                  InputBox(
                    controller: _firstNameCtrl,
                    label: 'Imię',
                    preset: InputPreset.text,
                    uppercase: true,
                  ),
                  const SizedBox(height: 12),
                  InputBox(
                    controller: _lastNameCtrl,
                    label: 'Nazwisko',
                    preset: InputPreset.text,
                    uppercase: true,
                  ),
                  const SizedBox(height: 12),
                  InputBox(
                    controller: _birthDateCtrl,
                    label: 'Data urodzenia',
                    hint: 'RRRR-MM-DD',
                    preset: InputPreset.dateYmd,
                  ),
                ],

                const SizedBox(height: 20),

                ButtonSearch(
                  onPressedAsync: () async {
                    await _onSearch();
                  },
                  enabled: true,
                  fullWidth: true,
                  label: 'Sprawdź osobę',
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

