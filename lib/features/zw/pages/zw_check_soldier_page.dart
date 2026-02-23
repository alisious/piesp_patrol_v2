// lib/features/zw/pages/zw_check_soldier_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/zw/data/zw_api.dart';
import 'package:piesp_patrol/features/zw/data/zw_zolnierz_dtos.dart';
import 'package:piesp_patrol/features/srp/data/person_controller.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/button_search.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class ZwCheckSoldierPage extends StatefulWidget {
  const ZwCheckSoldierPage({super.key});

  @override
  State<ZwCheckSoldierPage> createState() => _ZwCheckSoldierPageState();
}

class _ZwCheckSoldierPageState extends State<ZwCheckSoldierPage> {
  // PESEL field
  final _peselCtrl = TextEditingController();

  @override
  void dispose() {
    _peselCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Wyświetla dialog z wynikiem zapytania. Tło wg koloru (zielone = żołnierz, brak = standardowe). Czcionka standardowa. Zamyka się po kliknięciu Zamknij.
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

  ZwZolnierzByPeselRequestDto _buildRequest() {
    final peselText = _peselCtrl.text.trim();
    return ZwZolnierzByPeselRequestDto(
      pesel: peselText.isNotEmpty ? peselText : null,
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
      final zwApi = scope.zwApi as ZwApi;
      final req = _buildRequest();

      final resp = await zwApi.zolnierzByPesel(req);
      if (!mounted) return;

      final status = resp.status ?? -1;
      final msg = (resp.message?.isNotEmpty ?? false)
          ? resp.message!
          : (status == 0
              ? 'Zapytanie wykonane.'
              : 'Błąd zapytania.');

      if (status == 0 && resp.data != null) {
        // TODO: Nawigacja do strony wyników - zostanie dodana później
        _showResultDialog(
          'Znaleziono żołnierza: ${resp.data!.stopien ?? 'brak stopnia'} ${resp.data!.jednostka ?? 'brak jednostki'}',
          backgroundColor: Colors.green,
        );
      } else {
        // Nie znaleziono osoby lub błąd - tło standardowe (szare)
        if (status == 2) {
          _showResultDialog(msg);
        } else if (status == 0) {
          _showResultDialog('OK: $msg');
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
        title: 'Czy jest żołnierzem?',
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
                                        color: Theme.of(context).colorScheme.primary,
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

