// lib/features/srp/pages/person_details_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart';


class PersonDetailsResultPage extends StatelessWidget {
  const PersonDetailsResultPage({super.key, required this.person});
  final OsobaFullDto person;

  @override
  Widget build(BuildContext context) {
    //final isWide = Responsive.isDesktop(context) || Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły osoby'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               _section(
                context,
                title: 'Tożsamość',
                children: _rows({
                  'PESEL': person.numerPesel,
                  'Data aktualizacji': person.dataAktualizacji,
                  'Czy anulowano': person.czyAnulowano == null
                      ? null
                      : (person.czyAnulowano! ? 'tak' : 'nie'),
                }),
                initiallyExpanded: true,
              ),
              _section(
                context,
                title: 'Imię i nazwisko',
                children: _rows({
                  'Imię pierwsze': person.daneImion?.imiePierwsze,
                  'Imię drugie': person.daneImion?.imieDrugie,
                  'Nazwisko': person.daneNazwiska?.nazwisko,
                  'Nazwisko rodowe': person.daneNazwiska?.nazwiskoRodowe,
                }),
              ),
              _section(
                context,
                title: 'Urodzenie',
                children: _rows({
                  'Data urodzenia': person.daneUrodzenia?.dataUrodzenia,
                  'Płeć': person.daneUrodzenia?.plec,
                  'Imię matki': person.daneUrodzenia?.imieMatki,
                  'Nazwisko rodowe matki': person.daneUrodzenia?.nazwiskoRodoweMatki,
                  'Imię ojca': person.daneUrodzenia?.imieOjca,
                  'Nazwisko rodowe ojca': person.daneUrodzenia?.nazwiskoRodoweOjca,
                  'Kraj urodzenia': person.daneUrodzenia?.krajUrodzenia,
                  'Miejscowość urodzenia': person.daneUrodzenia?.miejscowoscUrodzenia,
                  'Nazwa USCW': person.daneUrodzenia?.nazwaUSCW,
                  'Kod TERC': person.daneUrodzenia?.kodTerc,
                  'Kod SIMC': person.daneUrodzenia?.kodSimc,
                  'Powiat': person.daneUrodzenia?.nazwaPowiat,
                  'Gmina': person.daneUrodzenia?.nazwaGmina,
                  'Numer aktu': person.daneUrodzenia?.numerAktu,
                }),
              ),
              _section(
                context,
                title: 'Obywatelstwo i stan cywilny',
                children: [
                  ..._rows({
                    'Obywatelstwo': person.daneObywatelstwa,
                  }),
                  const Divider(height: 16),
                  ..._rows({
                    'Stan cywilny': person.daneStanuCywilnego?.stanCywilny,
                    'Data zawarcia': person.daneStanuCywilnego?.dataZawarcia,
                    'Numer aktu': person.daneStanuCywilnego?.numerAktu,
                    'Zmiana płci': person.daneStanuCywilnego?.czyZmienianoPlec == null
                        ? null
                        : (person.daneStanuCywilnego!.czyZmienianoPlec! ? 'tak' : 'nie'),
                  }),
                  if (person.daneStanuCywilnego?.wspolmalzonek != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Współmałżonek', style: Theme.of(context).textTheme.titleMedium)
                    ),
                    const SizedBox(height: 6),
                    ..._rows({
                      'Imię': person.daneStanuCywilnego?.wspolmalzonek?.imie,
                      'Nazwisko': person.daneStanuCywilnego?.wspolmalzonek?.nazwisko,
                      'PESEL': person.daneStanuCywilnego?.wspolmalzonek?.pesel,
                    }),
                  ],
                ],
              ),
              _section(
                context,
                title: 'Dokumenty',
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Dowód osobisty', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 6),
                  ..._rows({
                    'Seria i numer': person.daneDowoduOsobistego?.seriaINumer,
                    'Data ważności': person.daneDowoduOsobistego?.dataWaznosci,
                    'Wystawca (nazwa)': person.daneDowoduOsobistego?.wystawca?.nazwaOrganu,
                  }),
                  const Divider(height: 20),
                  Text('Paszport', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  ..._rows({
                    'Seria i numer': person.danePaszportu?.seriaINumer,
                    'Data ważności': person.danePaszportu?.dataWaznosci,
                  }),
                ],
              ),
              _section(
                context,
                title: 'Pobyt stały',
                children: _addressRows(person.danePobytuStalego),
              ),
              _section(
                context,
                title: 'Pobyt czasowy',
                children: _addressRows(person.danePobytuCzasowego),
              ),
              _section(
                context,
                title: 'Kraje zamieszkania',
                children: _rows({
                  'Kraj zamieszkania': person.daneKrajowZamieszkania?.krajZamieszkania,
                  'Kod': person.daneKrajowZamieszkania?.kod,
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
    if (children.isEmpty) {
      // nic do pokazania — pomijamy sekcję
      return const SizedBox.shrink();
    }
    return Card(
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  List<Widget> _rows(Map<String, String?> items) {
    final list = <Widget>[];
    items.forEach((label, value) {
      final v = (value ?? '').trim();
      if (v.isNotEmpty) {
        list.add(_row(label, v));
      }
    });
    return list;
  }

  List<Widget> _addressRows(DanePobytuDto? pobyt) {
    if (pobyt == null) return const [];
    return _rows({
      'Województwo': pobyt.wojewodztwo,
      'Powiat': pobyt.powiat,
      'Gmina': pobyt.gmina,
      'Miejscowość': pobyt.miejscowosc,
      'Ulica (cecha)': pobyt.ulicaCecha,
      'Ulica (nazwa)': pobyt.ulicaNazwa,
      'Nr domu': pobyt.numerDomu,
      'Nr lokalu': pobyt.numerLokalu,
      'Kod pocztowy': pobyt.kodPocztowy,
      'Data od': pobyt.dataOd,
      'Adres ID (zameld.)': pobyt.adresZameldowaniaId,
    });
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
