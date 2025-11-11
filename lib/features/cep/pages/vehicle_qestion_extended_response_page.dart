// lib/features/cep/pages/vehicle_qestion_extended_response_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/cep/data/cep_pojazd_dtos.dart';

class VehicleQuestionExtendedResponsePage extends StatelessWidget {
  const VehicleQuestionExtendedResponsePage({
    super.key,
    required this.response,
  });

  final CepPytanieOPojazdRozszerzoneResponseDto response;

  @override
  Widget build(BuildContext context) {
    final pojazd = response.pojazdRozszerzone;
    final hasVehicleData = pojazd != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły pojazdu'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
             
              // Informacja o braku danych pojazdu
              if (!hasVehicleData)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Brak danych o pojeździe',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

              // Sekcje z danymi pojazdu (tylko gdy pojazd istnieje
              if (hasVehicleData) ...[
                // Dane opisujące pojazd
                if (pojazd.daneOpisujacePojazd != null)
                  _section(
                    context,
                    title: 'Dane opisujące pojazd',
                    children: _buildDaneOpisujacePojazdSection(context, pojazd.daneOpisujacePojazd!),
                  ),

                // Dane techniczne
                if (pojazd.daneTechnicznePojazdu != null)
                  _section(
                    context,
                    title: 'Dane techniczne',
                    children: _rows({
                      'Pojemność silnika (cm³)': pojazd.daneTechnicznePojazdu?.pojemnoscSilnika?.toString(),
                      'Moc silnika (KM)': pojazd.daneTechnicznePojazdu?.mocSilnika?.toString(),
                      'Masa własna (kg)': pojazd.daneTechnicznePojazdu?.masaWlasna?.toString(),
                      'Dopuszczalna masa całkowita (kg)': pojazd.daneTechnicznePojazdu?.dopuszczalnaMasaCalkowita?.toString(),
                      'Liczba miejsc ogółem': pojazd.daneTechnicznePojazdu?.liczbaMiejscOgolem?.toString(),
                    }),
                  ),

                // Dokumenty pojazdu
                if (pojazd.dokumentPojazdu.isNotEmpty)
                  _section(
                    context,
                    title: 'Dokumenty pojazdu',
                    children: _buildDocumentsSection(context, pojazd.dokumentPojazdu),
                  ),

                // Informacje SKP
                if (pojazd.informacjeSKP != null)
                  _section(
                    context,
                    title: 'Informacje SKP',
                    children: _buildInformacjeSKPSection(context, pojazd.informacjeSKP!),
                  ),

                // Polisa OC
                if (pojazd.danePolisyOC != null)
                  _section(
                    context,
                    title: 'Polisa OC',
                    children: _buildPolisaOCSection(context, pojazd.danePolisyOC!),
                  ),

                // Rejestracje pojazdu
                if (pojazd.rejestracjaPojazdu.isNotEmpty || pojazd.danePojazduSprowadzonego != null)
                  _section(
                    context,
                    title: 'Rejestracje pojazdu',
                    children: _buildRejestracjePojazduSection(context, pojazd),
                  ),

                // Podmiot (właściciel)
                if (pojazd.najnowszyWariantPodmiotu != null)
                  _section(
                    context,
                    title: 'Podmiot (właściciel)',
                    children: _buildPodmiotSection(context, pojazd.najnowszyWariantPodmiotu!),
                  ),
              ],

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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 200, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Widget> _buildDocumentsSection(
    BuildContext context,
    List<CepDokumentPojazduDto> dokumenty,
  ) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < dokumenty.length; i++) {
      final dok = dokumenty[i];
      
      if (i > 0) {
        widgets.add(const Divider(height: 16));
      }
      
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Dokument ${i + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      
      widgets.add(const SizedBox(height: 6));
      
      widgets.addAll(
        _rows({
          'Typ dokumentu': dok.typDokumentu?.wartoscOpisowa ?? dok.typDokumentu?.wartoscOpisowaSkrocona,
          'Seria i numer dokumentu': dok.dokumentSeriaNumer,
          'Data wydania dokumentu': dok.dataWydaniaDokumentu,
          'Czy aktualny': dok.czyAktualny == null
              ? null
              : (dok.czyAktualny! ? 'tak' : 'nie'),
        }),
      );
    }
    
    return widgets;
  }

  List<Widget> _buildDaneOpisujacePojazdSection(
    BuildContext context,
    CepDaneOpisujacePojazdDto dane,
  ) {
    return _rows({
      'Marka': dane.marka?.wartoscOpisowa,
      'Model': dane.model?.wartoscOpisowa,
      'Rodzaj': dane.rodzaj?.rodzaj,
      'Podrodzaj': dane.podrodzaj?.podrodzaj,
      'Przeznaczenie': dane.przeznaczenie?.przeznaczenie,
      'Numer podwozia/nadwozia/ramy (VIN)': dane.numerPodwoziaNadwoziaRamy,
      'Rok produkcji': dane.rokProdukcji?.toString(),
      'Pochodzenie pojazdu': dane.pochodzeniePojazdu?.wartoscOpisowaSkrocona,
      'Czy wybity numer identyfikacyjny': dane.czyWybityNumerIdentyfikacyjny?.wartoscOpisowaSkrocona,
      'Rodzaj tabliczki znamionowej': dane.rodzajTabliczkiZnamionowej?.wartoscOpisowaSkrocona,
      'Sposób produkcji': dane.sposobProdukcji?.wartoscOpisowaSkrocona,
    });
  }

  List<Widget> _buildInformacjeSKPSection(
    BuildContext context,
    CepInformacjeSkpDto informacjeSKP,
  ) {
    final widgets = <Widget>[];
    
    widgets.addAll(
      _rows({
        'Rodzaj czynności': informacjeSKP.rodzajCzynnosciSKP?.wartoscOpisowaSkrocona,
        'Numer zaświadczenia': informacjeSKP.numerZaswiadczenia,
        'Wynik czynności': informacjeSKP.wynikCzynnosci?.wartoscOpisowaSkrocona,
        'Wpis do dokumentu pojazdu': informacjeSKP.wpisDoDokumentuPojazdu == null
            ? null
            : (informacjeSKP.wpisDoDokumentuPojazdu! ? 'tak' : 'nie'),
        'Wydanie zaświadczenia': informacjeSKP.wydanieZaswiadczenia == null
            ? null
            : (informacjeSKP.wydanieZaswiadczenia! ? 'tak' : 'nie'),
        'Data i godz. wykonania czynności SKP': informacjeSKP.dataGodzWykonaniaCzynnosciSKP,
        'Tryb awaryjny': informacjeSKP.trybAwaryjny == null
            ? null
            : (informacjeSKP.trybAwaryjny! ? 'tak' : 'nie'),
        'Data kolejnego badania': informacjeSKP.terminKolejnegoBadaniaTechnicznego?.dataKolejnegoBadania,
      }),
    );

    // Stacja kontroli pojazdów
    if (informacjeSKP.stacjaKontroliPojazdow != null) {
      widgets.add(const Divider(height: 16));
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Stacja kontroli pojazdów',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.addAll(
        _rows({
          'Nazwa': informacjeSKP.stacjaKontroliPojazdow?.nazwa,
          'Numer ewidencyjny': informacjeSKP.stacjaKontroliPojazdow?.numerEwidencyjny,
          'REGON': informacjeSKP.stacjaKontroliPojazdow?.REGON,
        }),
      );
    }

    // Stan licznika
    if (informacjeSKP.stanLicznika != null) {
      widgets.add(const Divider(height: 16));
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Stan licznika',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.addAll(
        _rows({
          'Wartość stanu licznika': informacjeSKP.stanLicznika?.wartoscStanuLicznika?.toString(),
          'Jednostka stanu licznika': informacjeSKP.stanLicznika?.jednostkaStanuLicznika?.wartoscOpisowaSkrocona,
          'Data spisania licznika': informacjeSKP.stanLicznika?.dataSpisaniaLicznika,
          'Data odnotowania': informacjeSKP.stanLicznika?.dataOdnotowania,
        }),
      );
    }

    return widgets;
  }

  List<Widget> _buildPolisaOCSection(
    BuildContext context,
    CepDanePolisyOCDto danePolisyOC,
  ) {
    final widgets = <Widget>[];
    
    // Podstawowe dane polisy
    widgets.addAll(
      _rows({
        'Numer polisy': danePolisyOC.numerPolisy,
        'Data zawarcia polisy': danePolisyOC.dataZawarciaPolisy,
        'Data początku obowiązywania polisy': danePolisyOC.dataPoczatkuObowiazywaniaPolisy,
        'Data końca obowiązywania polisy': danePolisyOC.dataKoncaObowiazywaniaPolisy,
        'Rodzaj ubezpieczenia': danePolisyOC.rodzajUbezpieczenia?.wartoscOpisowaSkrocona ?? 
            danePolisyOC.rodzajUbezpieczenia?.wartoscOpisowa,
      }),
    );

    // Dane zakładu ubezpieczeń
    if (danePolisyOC.daneZU != null) {
      widgets.add(const Divider(height: 16));
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Zakład ubezpieczeń',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.addAll(
        _rows({
          'Nazwa zakładu ubezpieczeń': danePolisyOC.daneZU?.nazwaZakladuUbezpieczen,
          'Nazwa handlowa zakładu ubezpieczeniowego': danePolisyOC.daneZU?.nazwaHandlowaZakladuUbezpieczeniowego,
        }),
      );
    }

    // Wariant ubezpieczenia
    if (danePolisyOC.wariantUbezpieczenia != null) {
      widgets.add(const Divider(height: 16));
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Wariant ubezpieczenia',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.addAll(
        _rows({
          'Data początku wariantu': danePolisyOC.wariantUbezpieczenia?.dataPoczatkuWariantu,
          'Data końca wariantu': danePolisyOC.wariantUbezpieczenia?.dataKoncaWariantu,
        }),
      );
    }

    return widgets;
  }

  List<Widget> _buildRejestracjePojazduSection(
    BuildContext context,
    CepPojazdRozszerzoneDto pojazd,
  ) {
    final widgets = <Widget>[];
    
    // Rejestracje pojazdu
    if (pojazd.rejestracjaPojazdu.isNotEmpty) {
      for (int i = 0; i < pojazd.rejestracjaPojazdu.length; i++) {
        final rej = pojazd.rejestracjaPojazdu[i];
        
        if (i > 0) {
          widgets.add(const Divider(height: 16));
        }
        
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rejestracja ${i + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 6));
        
        widgets.addAll(
          _rows({
            'Data rejestracji pojazdu': rej.dataRejestracjiPojazdu,
            'Typ rejestracji': rej.typrejestracji?.wartoscOpisowaSkrocona ?? 
                rej.typrejestracji?.wartoscOpisowa,
          }),
        );
        
        // Organ rejestrujący
        if (rej.organRejestrujacy != null) {
          widgets.add(const SizedBox(height: 8));
          widgets.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Organ rejestrujący',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          );
          widgets.add(const SizedBox(height: 4));
          widgets.addAll(
            _rows({
              'Nazwa': rej.organRejestrujacy?.nazwa,
              'Numer ewidencyjny': rej.organRejestrujacy?.numerEwidencyjny,
              'REGON': rej.organRejestrujacy?.REGON,
              'Nazwa organu wydającego': rej.organRejestrujacy?.nazwaOrganuWydajacego,
            }),
          );
        }
      }
    }
    
    // Dane pojazdu sprowadzonego
    if (pojazd.danePojazduSprowadzonego != null) {
      if (widgets.isNotEmpty) {
        widgets.add(const Divider(height: 16));
      }
      
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pojazd sprowadzony',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      
      widgets.addAll(
        _rows({
          'Numer rejestracyjny zagraniczny': pojazd.danePojazduSprowadzonego?.numerRejestracyjnyZagraniczny,
          'Poprzedni VIN zagranicznej rejestracji': pojazd.danePojazduSprowadzonego?.poprzedniVINZagranicznejRejestracji,
        }),
      );
      
      // Kraj zagranicznej rejestracji
      if (pojazd.danePojazduSprowadzonego?.krajZagranicznejRejestracji != null) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kraj zagranicznej rejestracji',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        widgets.addAll(
          _rows({
            'Nazwa': pojazd.danePojazduSprowadzonego?.krajZagranicznejRejestracji?.nazwa,
            'Kod ISO Alpha-2': pojazd.danePojazduSprowadzonego?.krajZagranicznejRejestracji?.kodIsoAlfa2,
            'Kod ISO Alpha-3': pojazd.danePojazduSprowadzonego?.krajZagranicznejRejestracji?.kodIsoAlfa3,
            'Kod MKS': pojazd.danePojazduSprowadzonego?.krajZagranicznejRejestracji?.kodMks,
            'Czy należy do UE': pojazd.danePojazduSprowadzonego?.krajZagranicznejRejestracji?.czyNalezyDoUE == null
                ? null
                : (pojazd.danePojazduSprowadzonego!.krajZagranicznejRejestracji!.czyNalezyDoUE! ? 'tak' : 'nie'),
          }),
        );
      }
    }
    
    return widgets;
  }

  List<Widget> _buildPodmiotSection(
    BuildContext context,
    CepWlasnoscPodmiotuDto wlasnosc,
  ) {
    final widgets = <Widget>[];
    
    // Podstawowe dane własności
    widgets.addAll(
      _rows({
        'Kod własności': wlasnosc.kodWlasnosci?.wartoscOpisowaSkrocona ?? 
            wlasnosc.kodWlasnosci?.wartoscOpisowa,
        'Data zmiany praw własności': wlasnosc.dataZmianyPrawWlasnosci,
        'Data odnotowania': wlasnosc.dataOdnotowania,
      }),
    );
    
    // Zmiana własności
    if (wlasnosc.zmianaWlasnosci != null) {
      widgets.add(const Divider(height: 16));
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Zmiana własności',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.addAll(
        _rows({
          'Sposób zmiany praw własności': wlasnosc.zmianaWlasnosci?.sposobZmianyPrawWlasnosci?.wartoscOpisowaSkrocona ??
              wlasnosc.zmianaWlasnosci?.sposobZmianyPrawWlasnosci?.wartoscOpisowa,
          'Data odnotowania': wlasnosc.zmianaWlasnosci?.dataOdnotowania,
        }),
      );
    }
    
    // Podmiot
    if (wlasnosc.podmiot != null) {
      if (widgets.isNotEmpty) {
        widgets.add(const Divider(height: 16));
      }
      
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Podmiot',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      
      
      // Firma
      if (wlasnosc.podmiot?.firma != null) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Firma',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        widgets.addAll(
          _rows({
            'REGON': wlasnosc.podmiot?.firma?.REGON,
            'Nazwa firmy': wlasnosc.podmiot?.firma?.nazwaFirmy,
            'Nazwa firmy drukowana': wlasnosc.podmiot?.firma?.nazwaFirmyDrukowana,
            'Forma własności': wlasnosc.podmiot?.firma?.formaWlasnosci?.wartoscOpisowaSkrocona ??
                wlasnosc.podmiot?.firma?.formaWlasnosci?.wartoscOpisowa,
            'Identyfikator systemowy REGON': wlasnosc.podmiot?.firma?.identyfikatorSystemowyREGON,
          }),
        );
        
        // Adres
        final adres = wlasnosc.podmiot?.firma?.adres;
        if (adres != null) {
          widgets.add(const SizedBox(height: 8));
          widgets.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Adres',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          );
          widgets.add(const SizedBox(height: 4));
          
          final ulicaText = adres.ulicaCecha != null && adres.nazwaUlicy != null
              ? '${adres.ulicaCecha!.wartoscOpisowaSkrocona ?? adres.ulicaCecha!.wartoscOpisowa ?? ''} ${adres.nazwaUlicy}'.trim()
              : adres.nazwaUlicy;
          
          widgets.addAll(
            _rows({
              'Kraj': adres.kraj?.nazwa,
              'Kod pocztowy': adres.kodPocztowy,
              'Miejscowość': adres.nazwaMiejscowosci,
              'Ulica': ulicaText,
              'Numer domu': adres.numerDomu,
              'Numer lokalu': adres.numerLokalu,
              'Województwo': adres.nazwaWojewodztwaStanu,
              'Powiat': adres.nazwaPowiatuDzielnicy,
              'Gmina': adres.nazwaGminy,
              'Kod TERYT': adres.kodTeryt,
            }),
          );
        }
      }
    }
    
    return widgets;
  }
}
