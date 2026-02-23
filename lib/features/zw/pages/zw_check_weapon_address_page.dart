// lib/features/zw/pages/zw_check_weapon_address_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/zw/data/zw_api.dart';
import 'package:piesp_patrol/features/zw/data/zw_bron_dtos.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/button_search.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class ZwCheckWeaponAddressPage extends StatefulWidget {
  const ZwCheckWeaponAddressPage({super.key});

  @override
  State<ZwCheckWeaponAddressPage> createState() => _ZwCheckWeaponAddressPageState();
}

class _ZwCheckWeaponAddressPageState extends State<ZwCheckWeaponAddressPage> {
  // Address fields
  final _miejscowoscCtrl = TextEditingController();
  final _ulicaCtrl = TextEditingController();
  final _numerDomuCtrl = TextEditingController();
  final _numerLokaluCtrl = TextEditingController();
  final _kodPocztowyCtrl = TextEditingController();
  final _pocztaCtrl = TextEditingController();

  @override
  void dispose() {
    _miejscowoscCtrl.dispose();
    _ulicaCtrl.dispose();
    _numerDomuCtrl.dispose();
    _numerLokaluCtrl.dispose();
    _kodPocztowyCtrl.dispose();
    _pocztaCtrl.dispose();
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

  String? _validateRequest() {
    // Sprawdź wymagane pola: miejscowość i numer domu
    final miejscowosc = _miejscowoscCtrl.text.trim();
    final numerDomu = _numerDomuCtrl.text.trim();

    if (miejscowosc.isEmpty) {
      return 'Podaj miejscowość.';
    }

    if (numerDomu.isEmpty) {
      return 'Podaj numer domu.';
    }

    return null;
  }

  ZwBronByAddressRequestDto _buildRequest() {
    return ZwBronByAddressRequestDto(
      miejscowosc: _nullIfEmpty(_miejscowoscCtrl.text),
      ulica: _nullIfEmpty(_ulicaCtrl.text),
      numerDomu: _nullIfEmpty(_numerDomuCtrl.text),
      numerLokalu: _nullIfEmpty(_numerLokaluCtrl.text),
      kodPocztowy: _nullIfEmpty(_kodPocztowyCtrl.text),
      poczta: _nullIfEmpty(_pocztaCtrl.text),
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

      final resp = await zwApi.bronByAddress(req);
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
          // Znaleziono broń - wyświetl czerwony komunikat
          final pierwszyAdres = data.adresy.first;
          final opis = pierwszyAdres.opis ?? 'brak opisu';
          _showResultDialog(
            'Pod podanym adresem może znajdować się broń: $opis',
            backgroundColor: Colors.red,
          );
        } else {
          // Brak adresów z bronią - zielone tło
          _showResultDialog(
            'Znaleziono dane osoby (PESEL: $pesel), ale brak adresów z bronią.',
            backgroundColor: Colors.green,
          );
        }
      } else {
        // Status 1, 2 lub 0 (nie znaleziono lokalizacji) - wyświetl komunikat informacyjny
        if (status == 1 || status == 2 || status == 0) {
          _showResultDialog(
            'Nie znaleziono informacji o broni pod podanym adresem.',
            backgroundColor: Colors.green,
          );
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
        title: 'Czy może być tam broń?',
        showBack: true,
      ),
      body: PageContainer(
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tekst informacyjny o wymaganych polach
                const Text(
                  'Wymagane pola: Miejscowość, Numer domu.',
                ),
                const SizedBox(height: 16),

                // Miejscowość field
                InputBox(
                  controller: _miejscowoscCtrl,
                  label: 'Miejscowość',
                  preset: InputPreset.text,
                  uppercase: true,
                ),
                const SizedBox(height: 12),

                // Ulica field
                InputBox(
                  controller: _ulicaCtrl,
                  label: 'Ulica',
                  preset: InputPreset.text,
                  uppercase: true,
                ),
                const SizedBox(height: 12),

                // Numer domu field
                InputBox(
                  controller: _numerDomuCtrl,
                  label: 'Numer domu',
                  preset: InputPreset.text,
                  uppercase: true,
                ),
                const SizedBox(height: 12),

                // Numer lokalu field
                InputBox(
                  controller: _numerLokaluCtrl,
                  label: 'Numer lokalu',
                  preset: InputPreset.text,
                  uppercase: true,
                ),
                const SizedBox(height: 12),

                // Kod pocztowy field
                InputBox(
                  controller: _kodPocztowyCtrl,
                  label: 'Kod pocztowy',
                  preset: InputPreset.text,
                ),
                const SizedBox(height: 12),

                // Poczta field
                InputBox(
                  controller: _pocztaCtrl,
                  label: 'Poczta',
                  preset: InputPreset.text,
                  uppercase: true,
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

  String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

