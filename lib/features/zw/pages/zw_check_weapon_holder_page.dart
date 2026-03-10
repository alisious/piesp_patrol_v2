// lib/features/zw/pages/zw_check_weapon_holder_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/srp/data/person_controller.dart';
import 'package:piesp_patrol/features/srp/data/srp_api.dart';
import 'package:piesp_patrol/features/zw/data/zw_api.dart';
import 'package:piesp_patrol/features/zw/data/zw_bron_dtos.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/wanted_splash.dart';
import 'package:piesp_patrol/widgets/button_search.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class ZwCheckWeaponHolderPage extends StatefulWidget {
  const ZwCheckWeaponHolderPage({super.key});

  @override
  State<ZwCheckWeaponHolderPage> createState() => _ZwCheckWeaponHolderPageState();
}

class _ZwCheckWeaponHolderPageState extends State<ZwCheckWeaponHolderPage> {
  // PESEL field
  final _peselCtrl = TextEditingController();

  @override
  void dispose() {
    _peselCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Wyświetla dialog z wynikiem sprawdzenia. Tło dialogu w odpowiednim kolorze, czcionka standardowa. Zamyka się dopiero po kliknięciu Zamknij.
  void _showResultDialog(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: backgroundColor ?? theme.dialogBackgroundColor,
        title: const Text('Wynik sprawdzenia'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  /// Wypełnia pole PESEL danymi z wybranej osoby.
  void _fillFieldsFromSelectedPerson() {
    final personController = AppScope.of(context).personController as PersonController;
    final selectedPerson = personController.selectedPerson;

    if (selectedPerson == null) {
      _showSnack('Brak wybranej osoby.');
      return;
    }

    setState(() {
      // Wypełnij pole PESEL
      _peselCtrl.text = selectedPerson.pesel ?? '';
    });

    _showSnack('Wypełniono pole PESEL danymi wybranej osoby.');
  }

  String? _validateRequest() {
    final peselText = _peselCtrl.text.trim();
    if (peselText.isEmpty) {
      return 'Podaj numer PESEL.';
    }
    if (peselText.length != 11) {
      return 'PESEL musi mieć 11 cyfr.';
    }
    return null;
  }

  ZwBronByPeselRequestDto _buildRequest() {
    final peselText = _peselCtrl.text.trim();
    return ZwBronByPeselRequestDto(
      pesel: peselText.isNotEmpty ? peselText : null,
    );
  }

  Future<void> _onSearch() async {
    final validationError = _validateRequest();
    if (validationError != null) {
      _showSnack(validationError);
      return;
    }

    final pesel = _peselCtrl.text.trim();
    final scope = AppScope.of(context);
    final personController = scope.personController as PersonController;
    final selectedPerson = personController.selectedPerson;

    final needWantedCheck = (pesel != (selectedPerson?.pesel ?? '').trim()) ||
        (selectedPerson?.czyPoszukiwana == null && pesel == (selectedPerson?.pesel ?? '').trim());

    if (needWantedCheck) {
      final srpApi = scope.srpApi as SrpApi;
      final result = await srpApi.checkIfWanted(pesel: pesel);
      if (!mounted) return;

      if (result.isOk && result.value == true) {
        await showWantedSplash(context);
        if (!mounted) return;
      }
      if (result.isOk && selectedPerson != null && pesel == (selectedPerson.pesel ?? '').trim()) {
        personController.updateSelectedPerson(
          (p) => p.copyWith(czyPoszukiwana: result.value),
        );
      }
    }
    if (!mounted) return;

    try {
      final zwApi = scope.zwApi as ZwApi;
      final req = _buildRequest();

      final resp = await zwApi.bronByPesel(req);
      if (!mounted) return;

      final status = resp.status ?? -1;
      final msg = (resp.message?.isNotEmpty ?? false)
          ? resp.message!
          : (status == 0
              ? 'Zapytanie wykonane.'
              : 'Błąd zapytania.');

      if (status == 0 && resp.data != null) {
        // TODO: Nawigacja do strony wyników - zostanie dodana później
        final data = resp.data!;
        final adresyCount = data.adresy.length;
        final pesel = data.pesel ?? 'brak';
        if (adresyCount > 0) {
          final pierwszyAdres = data.adresy.first;
          final opis = pierwszyAdres.opis ?? 'brak opisu';
          _showResultDialog(
            'Osoba z PESEL = $pesel może posiadać broń: $opis.',
            backgroundColor: Colors.red,
          );
        } else {
          _showResultDialog(
            'Znaleziono dane osoby (PESEL: $pesel), ale brak adresów z bronią.',
            backgroundColor: Colors.green,
          );
        }
      } else {
        // Status 1, 2 lub 0 (brak danych/informacja biznesowa) - wyświetl tylko message bez prefiksu "Błąd"
        // Status 1 = nie znaleziono informacji
        // Status 2 = brak danych/informacja biznesowa
        // Status 0 bez danych = nie znaleziono informacji
        if (status == 1 || status == 2 || status == 0) {
          _showResultDialog(msg, backgroundColor: Colors.green);
        } else {
          _showResultDialog('Błąd ($status): $msg');
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showResultDialog('Wyjątek: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Czy posiada broń prywatną?',
        showBack: true,
      ),
      body: PageContainer(
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final personController = AppScope.of(context).personController as PersonController;
                    return Row(
                      children: [
                        const Expanded(
                          child: SizedBox.shrink(),
                        ),
                        AnimatedBuilder(
                          animation: personController,
                          builder: (context, _) {
                            final hasSelectedPerson = personController.selectedPerson != null;

                            if (hasSelectedPerson) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Tooltip(
                                  message: 'Wypełnij pole PESEL danymi wybranej osoby',
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

                // PESEL field
                InputBox(
                  controller: _peselCtrl,
                  label: 'PESEL',
                  preset: InputPreset.pesel,
                ),

                const SizedBox(height: 20),

                ButtonSearch(
                  onPressedAsync: () async {
                    await _onSearch();
                  },
                  enabled: true,
                  fullWidth: true,
                  label: 'Sprawdź',
                  icon: Icons.search,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

