// lib/features/cep/pages/upki_check_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/cep/data/upki_dtos.dart';

class UpKiCheckResultPage extends StatelessWidget {
  const UpKiCheckResultPage({
    super.key,
    required this.response,
  });

  final UpKiResponseDto response;

  @override
  Widget build(BuildContext context) {
    final dokumenty = response.dokumentyUprawnieniaKierowcy ?? [];
    final hasData = dokumenty.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uprawnienia kierowcy'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Informacja o braku danych
              if (!hasData)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      response.komunikat ?? 'Brak dokumentów uprawnień kierowcy',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

              // Komunikat ogólny
              if (response.komunikat != null && hasData)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      response.komunikat!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

              // Dane zapytania
              if (response.dataZapytania != null)
                _section(
                  context,
                  title: 'Data zapytania',
                  children: _rows({
                    'Data zapytania': response.dataZapytania,
                  }),
                  initiallyExpanded: false,
                ),

              // Dane kierowcy (z pierwszego dokumentu, jeśli dostępne)
              if (hasData && dokumenty.first.parametrOsobaId?.daneKierowcy != null)
                _section(
                  context,
                  title: 'Dane kierowcy',
                  children: _buildDaneKierowcySection(context, dokumenty.first.parametrOsobaId!.daneKierowcy!),
                  initiallyExpanded: true,
                ),

              // Dokumenty uprawnień kierowcy
              if (hasData)
                _section(
                  context,
                  title: 'Dokumenty uprawnień kierowcy (${dokumenty.length})',
                  children: _buildDokumentySection(context, dokumenty),
                  initiallyExpanded: true,
                ),
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
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDaneKierowcySection(
    BuildContext context,
    UpKiDaneKierowcyDto daneKierowcy,
  ) {
    final widgets = <Widget>[];

    // Podstawowe dane
    widgets.addAll(
      _rows({
        'PESEL': daneKierowcy.numerPesel,
        'Imię': daneKierowcy.imiePierwsze,
        'Nazwisko': daneKierowcy.nazwisko,
        'Data urodzenia': _formatDate(daneKierowcy.dataUrodzenia),
        'Miejsce urodzenia': daneKierowcy.miejsceUrodzenia,
      }),
    );

    // Adres
    if (daneKierowcy.adres != null) {
      widgets.add(const Divider(height: 16));
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Adres',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));

      final adres = daneKierowcy.adres!;
      final ulicaText = adres.ulica != null
          ? '${adres.ulica!.cechaUlicy?.wartoscOpisowa ?? ''} ${adres.ulica!.nazwaUlicy ?? ''}'.trim()
          : null;

      widgets.addAll(
        _rows({
          'Kraj': adres.kraj?.wartoscOpisowa,
          'Kod pocztowy': adres.miejsce?.kodPocztowyKrajowy,
          'Miejscowość': adres.miejsce?.nazwaMiejscowosci ?? adres.miejscowoscPodstawowa?.nazwaMiejscowosciPodstawowej,
          'Ulica': ulicaText,
          'Numer domu': adres.ulica?.nrDomu,
          'Numer lokalu': adres.nrLokalu,
          'Województwo': adres.miejsce?.nazwaWojewodztwaStanu,
          'Powiat': adres.miejsce?.nazwaPowiatuDzielnicy,
          'Gmina': adres.miejsce?.nazwaGminy,
          'Kod TERYT': adres.miejsce?.kodTERYT,
        }),
      );
    }

    return widgets;
  }

  List<Widget> _buildDokumentySection(
    BuildContext context,
    List<UpKiDokumentUprawnieniaKierowcyDto> dokumenty,
  ) {
    final widgets = <Widget>[];

    for (var i = 0; i < dokumenty.length; i++) {
      final dokument = dokumenty[i];
      if (i > 0) {
        widgets.add(const Divider(height: 24));
      }

      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Dokument ${i + 1}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      // Podstawowe informacje o dokumencie
      widgets.addAll(
        _rows({
          'ID dokumentu': dokument.dokumentId,
          'Typ dokumentu': dokument.typDokumentu?.wartoscOpisowa,
          'Numer dokumentu': dokument.numerDokumentu,
          'Seria i numer dokumentu': dokument.seriaNumerDokumentu,
          'Organ wydający': dokument.organWydajacyDokument?.wartoscOpisowa,
          'Data wydania': _formatDate(dokument.dataWydania),
          'Data ważności': _formatDate(dokument.dataWaznosci),
          'Stan dokumentu': dokument.stanDokumentu?.stanDokumentu?.wartoscOpisowa,
        }),
      );

      // Szczegóły stanu dokumentu
      if (dokument.stanDokumentu != null) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Szczegóły stanu dokumentu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        final stan = dokument.stanDokumentu!;
        final stanRows = <String, String?>{};
        if (stan.stanDokumentu != null) {
          stanRows['Stan'] = stan.stanDokumentu!.wartoscOpisowa ?? stan.stanDokumentu!.kod;
        }
        stanRows['Data zmiany stanu'] = _formatDate(stan.dataZmianyStanu);
        if (stan.podmiotZmianyStanu != null) {
          stanRows['Podmiot zmiany stanu'] = stan.podmiotZmianyStanu!.wartoscOpisowa ?? stan.podmiotZmianyStanu!.kod;
        }
        widgets.addAll(_rows(stanRows));
        
        // Powód zmiany stanu
        if (stan.powodZmianyStanu != null && stan.powodZmianyStanu!.isNotEmpty) {
          widgets.add(const SizedBox(height: 4));
          widgets.add(
            Text(
              'Powód zmiany stanu:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          );
          for (var powod in stan.powodZmianyStanu!) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  '• ${powod.wartoscOpisowa ?? powod.kod ?? '-'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }
        }
      }

      // Parametr osoba ID
      if (dokument.parametrOsobaId != null) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Identyfikacja',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        widgets.addAll(
          _rows({
            'Osoba ID': dokument.parametrOsobaId?.osobaId,
            'Wariant ID': dokument.parametrOsobaId?.wariantId,
            'Token kierowcy': dokument.parametrOsobaId?.tokenKierowcy,
            'IDK': dokument.parametrOsobaId?.idk,
          }),
        );
      }

      // Zakazy cofnięcia na poziomie dokumentu
      if (dokument.daneZakazuCofniecia != null && dokument.daneZakazuCofniecia!.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Zakazy cofnięcia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        for (var zakaz in dokument.daneZakazuCofniecia!) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZAKAZ PROWADZENIA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (zakaz.typZdarzenia != null)
                      Text(
                        zakaz.typZdarzenia!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    if (zakaz.dataDo != null)
                      Text(
                        'Data do: ${_formatDate(zakaz.dataDo)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      }

      // Ograniczenia
      if (dokument.ograniczenia != null && dokument.ograniczenia!.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ograniczenia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        for (var ograniczenie in dokument.ograniczenia!) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Kod: ${ograniczenie.kodOgraniczenia ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ograniczenie.opisKodu ?? ograniczenie.wartoscOgraniczenia ?? '-'),
                        if (ograniczenie.dataDo != null)
                          Text('Data do: ${_formatDate(ograniczenie.dataDo)}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      // Kategorie prawa jazdy
      if (dokument.daneUprawnieniaKategorii != null && dokument.daneUprawnieniaKategorii!.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kategorie prawa jazdy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));

        for (var kategoria in dokument.daneUprawnieniaKategorii!) {
          widgets.add(
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategoria: ${kategoria.kategoria?.wartoscOpisowa ?? kategoria.kategoria?.kod ?? '-'}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._rows({
                      'Data wydania': _formatDate(kategoria.dataWydania),
                      'Data ważności': _formatDate(kategoria.dataWaznosci),
                    }),
                    // Zakazy cofnięcia
                    if (kategoria.daneZakazuCofniecia != null && kategoria.daneZakazuCofniecia!.isNotEmpty)
                      ...kategoria.daneZakazuCofniecia!.map((zakaz) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ZAKAZ PROWADZENIA',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (zakaz.typZdarzenia != null)
                                Text(
                                  zakaz.typZdarzenia!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                              if (zakaz.dataDo != null)
                                Text(
                                  'Data do: ${_formatDate(zakaz.dataDo)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )),
                    // Ograniczenia kategorii
                    if (kategoria.ograniczenia != null && kategoria.ograniczenia!.isNotEmpty)
                      ...kategoria.ograniczenia!.map((ograniczenie) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Ograniczenie: ${ograniczenie.opisKodu ?? ograniczenie.wartoscOgraniczenia ?? ograniczenie.kodOgraniczenia ?? '-'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )),
                  ],
                ),
              ),
            ),
          );
        }
      }

      // Komunikat biznesowy
      if (dokument.komunikatBiznesowy != null) {
        final komunikat = dokument.komunikatBiznesowy!;
        if ((komunikat.kod != null && komunikat.kod!.trim().isNotEmpty) ||
            (komunikat.opis != null && komunikat.opis!.trim().isNotEmpty)) {
          widgets.add(const SizedBox(height: 8));
          widgets.add(
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (komunikat.kod != null && komunikat.kod!.trim().isNotEmpty)
                      Text(
                        'Kod: ${komunikat.kod!}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (komunikat.kod != null && komunikat.kod!.trim().isNotEmpty &&
                        komunikat.opis != null && komunikat.opis!.trim().isNotEmpty)
                      const SizedBox(height: 4),
                    if (komunikat.opis != null && komunikat.opis!.trim().isNotEmpty)
                      Text(
                        komunikat.opis!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return null;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString; // Jeśli nie można sparsować, zwróć oryginał
    }
  }
}

