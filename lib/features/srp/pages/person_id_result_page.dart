// lib/features/srp/pages/person_id_result_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/srp/data/person_id_dtos.dart';

class PersonIdResultPage extends StatelessWidget {
  const PersonIdResultPage({super.key, required this.dowod});
  final DowodOsobistyDto dowod;

  Uint8List? _decodeBase64Image(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Obsługa wariantów: czysty base64 lub data URI "data:image/jpeg;base64,...."
    final idx = s.indexOf('base64,');
    final base64Part = idx > 0 ? s.substring(idx + 'base64,'.length) : s;
    try {
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final b64Color = _decodeBase64Image(dowod.zdjecieKolorowe);
    final b64Gray  = _decodeBase64Image(dowod.zdjecieCzarnoBiale);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dowód osobisty'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zdjęcie – preferuj kolor, jeśli brak to B/W
            if (b64Color != null || b64Gray != null)
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.memory(b64Color ?? b64Gray!),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            _section(
              context,
              title: 'Dane dokumentu',
              children: _rows({
                'Seria i numer': dowod.seriaNumerDowodu,
                'Data wydania': dowod.dataWydania,
                'Data ważności': dowod.dataWaznosci,
                'Status dokumentu': dowod.statusDokumentu,
                'Status eDO': dowod.statusWarstwyEdo,
                'Obywatelstwo': dowod.obywatelstwo,
                'Kod TERYT urzędu': dowod.kodTerytUrzeduWydajacego,
                'Nazwa urzędu wydającego': dowod.nazwaUrzeduWydajacego,
              }),
              initiallyExpanded: true,
            ),

            _section(
              context,
              title: 'Dane osobowe',
              children: _rows({
                'Imię pierwsze': dowod.daneOsobowe?.imie?.imiePierwsze,
                'Imię drugie': dowod.daneOsobowe?.imie?.imieDrugie,
                'Nazwisko (człon 1)': dowod.daneOsobowe?.nazwisko?.czlonPierwszy,
                'Nazwisko (człon 2)': dowod.daneOsobowe?.nazwisko?.czlonDrugi,
                'Nazwisko rodowe': dowod.daneOsobowe?.nazwiskoRodowe,
                'PESEL': dowod.daneOsobowe?.pesel
              }),
            ),

            _section(
              context,
              title: 'Dane urodzenia',
              children: _rows({
                'Data urodzenia': dowod.daneUrodzenia?.dataUrodzenia,
                'Miejsce urodzenia': dowod.daneUrodzenia?.miejsceUrodzenia,
                'Płeć': dowod.daneUrodzenia?.plec,
                'Imię matki': dowod.daneUrodzenia?.imieMatki,
                'Imię ojca': dowod.daneUrodzenia?.imieOjca,
              }),
            ),

            _section(
              context,
              title: 'Wystawca',
              children: _rows({
                 'Nazwa wystawcy': dowod.daneWystawcy?.nazwaWystawcy,
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: cs.onSurface,
          collapsedIconColor: cs.onSurface,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: children,
        ),
      ),
    );
  }

  List<Widget> _rows(Map<String, String?> data) {
    return data.entries
        .where((e) => (e.value ?? '').trim().isNotEmpty)
        .map((e) => _row(e.key, e.value!))
        .toList();
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
