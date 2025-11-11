// lib/features/cep/pages/upki_check_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/cep/data/cep_api.dart';
import 'package:piesp_patrol/features/cep/data/upki_dtos.dart';
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
  // Selection: PESEL or Person data
  bool _usePesel = true;

  // PESEL fields
  final _peselCtrl = TextEditingController();

  // Person fields
  final _imieCtrl = TextEditingController();
  final _nazwiskoCtrl = TextEditingController();
  final _dataUrodzeniaCtrl = TextEditingController();

  @override
  void dispose() {
    _peselCtrl.dispose();
    _imieCtrl.dispose();
    _nazwiskoCtrl.dispose();
    _dataUrodzeniaCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(message)));
  }

  UpKiRequest _buildRequest() {
    // Automatycznie ustaw datę zapytania na bieżący czas (UTC, ISO 8601)
    final dataZapytania = DateTime.now().toUtc().toIso8601String();
    
    if (_usePesel) {
      return UpKiRequest(
        danePesel: UpKiDanePesel(
          numerPesel: _nullIfEmpty(_peselCtrl.text),
          dataZapytania: dataZapytania,
        ),
      );
    } else {
      return UpKiRequest(
        daneOsoby: UpKiDaneOsoby(
          imiePierwsze: _nullIfEmpty(_imieCtrl.text),
          nazwisko: _nullIfEmpty(_nazwiskoCtrl.text),
          dataUrodzenia: _nullIfEmpty(_dataUrodzeniaCtrl.text),
          dataZapytania: dataZapytania,
        ),
      );
    }
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
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('PESEL'),
                      icon: Icon(Icons.badge),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Dane osoby'),
                      icon: Icon(Icons.person),
                    ),
                  ],
                  selected: {_usePesel},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _usePesel = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),

                if (_usePesel) ...[
                  // PESEL fields
                  InputBox(
                    controller: _peselCtrl,
                    label: 'PESEL',
                    preset: InputPreset.pesel,
                    prefixIcon: Icons.badge,
                  ),
                ] else ...[
                  // Person fields
                  InputBox(
                    controller: _imieCtrl,
                    label: 'Imię pierwsze',
                    preset: InputPreset.text,
                    uppercase: true,
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  InputBox(
                    controller: _nazwiskoCtrl,
                    label: 'Nazwisko',
                    preset: InputPreset.text,
                    uppercase: true,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  InputBox(
                    controller: _dataUrodzeniaCtrl,
                    label: 'Data urodzenia',
                    hint: 'RRRR-MM-DD',
                    preset: InputPreset.dateYmd,
                    prefixIcon: Icons.cake,
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

