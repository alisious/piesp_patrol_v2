// lib/features/srp/pages/person_data_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class PersonDataResultPage extends StatelessWidget {
  const PersonDataResultPage({super.key, required this.person});
  final OsobaFullDto person;

  @override
  Widget build(BuildContext context) {
    final imiona = [
      person.daneImion?.pierwsze,
      person.daneImion?.drugie
    ].where((e) => (e ?? '').isNotEmpty).join(' ');
    final tytul = [imiona, person.daneNazwiska?.nazwisko]
        .where((e) => (e ?? '').isNotEmpty)
        .join(' ');

    return Scaffold(
      appBar: AppBar(title: Text(tytul.isEmpty ? 'Dane osoby' : tytul)),
      body: ResponsiveCenter(
        maxContentWidth: 480,
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _section(context, 'Identyfikacja', [
              _row('PESEL', person.numerPesel),
              _row('ID osoby', person.idOsoby),
              _row('Anulowano', person.czyAnulowano == true ? 'TAK' : 'NIE'),
              _row('Data aktualizacji', person.dataAktualizacji),
            ]),
            _section(context, 'Dane osobowe', [
              _row('Imię pierwsze', person.daneImion?.pierwsze),
              _row('Imię drugie', person.daneImion?.drugie),
              _row('Nazwisko', person.daneNazwiska?.nazwisko),
              _row('Obywatelstwo', person.daneObywatelstwa?.obywatelstwo),
            ]),
            _section(context, 'Urodzenie/Zgon', [
              _row('Data urodzenia', person.daneUrodzenia?.data),
              _row('Miejsce urodzenia', person.daneUrodzenia?.miejsce),
              _row('Data zgonu', person.daneZgonu?.data),
            ]),
            _section(context, 'Pobyt', [
              _row('Kraj', person.danePobytu?.kraj),
              _row('Województwo', person.danePobytu?.wojewodztwo),
              _row('Od', person.danePobytu?.dataOd),
            ]),
            _section(context, 'Dowód osobisty', [
              _row('Seria i numer', person.daneDowoduOsobistego?.seriaINumer),
              _row('Ważny do', person.daneDowoduOsobistego?.dataWaznosci),
              _row('Wystawca (rodzaj)', person.daneDowoduOsobistego?.wystawca?.rodzajOrganu),
              _row('Wystawca (TERYT)', person.daneDowoduOsobistego?.wystawca?.kodTerytorialny),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext ctx, String title, List<Widget> rows) {
    final theme = Theme.of(ctx);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
