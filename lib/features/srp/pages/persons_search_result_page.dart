// lib/features/srp/pages/persons_search_result_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/srp/data/srp_api.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart';
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart';
import 'package:piesp_patrol/widgets/responsive.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart';
import 'package:piesp_patrol/core/routing/routes.dart';



class PersonsSearchResultPage extends StatelessWidget {
  const PersonsSearchResultPage({super.key, required this.results});
  final List<OsobaZnalezionaDto> results;

  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    

    return Scaffold(
      appBar: AppBar(
        title: Text('Znalezione osoby (${results.length})'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.surfaceTint,
      ),
      body: ResponsiveCenter(
        maxContentWidth: 480,
        padding: const EdgeInsets.all(12),
        child: results.isEmpty
            ? Center(
                child: Text(
                  'Brak wyników.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              )
            : ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _PersonCard(person: results[i]),
              ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});
  final OsobaZnalezionaDto person;
  
  
  
  

  Uint8List? _decodeBase64Image(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Obsługa wariantu data URI: "data:image/jpeg;base64,..."
    final base64Part = s.startsWith('data:image')
        ? (s.split(',').length > 1 ? s.split(',').last : '')
        : s;

    if (base64Part.isEmpty) return null;
    try {
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bytes = _decodeBase64Image(person.zdjecie);

    final titleText = [
      if ((person.nazwisko ?? '').isNotEmpty) person.nazwisko,
      if ((person.imiePierwsze ?? '').isNotEmpty) person.imiePierwsze,
      if ((person.imieDrugie ?? '').isNotEmpty) person.imieDrugie,
    ].whereType<String>().join(' ');

    final subtitleLines = <String>[
      if ((person.pesel ?? '').isNotEmpty) 'PESEL: ${person.pesel}',
      if ((person.dataUrodzenia ?? '').isNotEmpty)
        'Data ur.: ${person.dataUrodzenia}',
      if ((person.miejsceUrodzenia ?? '').isNotEmpty)
        'Miejsce ur.: ${person.miejsceUrodzenia}',
      if ((person.plec ?? '').isNotEmpty) 'Płeć: ${person.plec}',
      if (person.czyZyje != null) 'Czy żyje: ${person.czyZyje! ? 'TAK' : 'NIE'}',
      if (person.czyPeselAnulowany != null)
        'PESEL anulowany: ${person.czyPeselAnulowany! ? 'TAK' : 'NIE'}',
      if ((person.seriaINumerDowodu ?? '').isNotEmpty)
        'Dowód: ${person.seriaINumerDowodu}',
      if ((person.idOsoby ?? '').isNotEmpty) 'ID osoby: ${person.idOsoby}',
    ];

    String shortPersonLabel() {
      if (titleText.isNotEmpty) return titleText;
      if ((person.pesel ?? '').isNotEmpty) return 'PESEL ${person.pesel}';
      return 'Osoba';
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.none, // proste rogi zdjęcia
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- FOTO (na górze panelu) — ~2/3 szerokości ekranu smartfona ---
          if (bytes != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final screenW = MediaQuery.of(context).size.width;
                final isNarrow = screenW < 600;
                final maxW = isNarrow ? screenW * 0.66 : 320.0;

                return Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                );
              },
            ),

          // --- Treść ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortPersonLabel(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (subtitleLines.isNotEmpty)
                    Text(
                      subtitleLines.join('\n'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- Arrow buttons nad „Wybierz” ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                ArrowButton(
                  title: 'Więcej informacji',
                  onTap: () async { 
                    final s = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    
                    s.hideCurrentSnackBar();
                    s.showSnackBar(const SnackBar(content: Text('Pobieram dane osoby ...')));

                     try {
                      final srpApi = AppScope.of(context).srpApi as SrpApi;
                      final result = await srpApi.getPersonByPesel(
                        request: GetPersonByPeselRequestDto(pesel: person.pesel),
                      );

                      if (result.isOk && result.value != null) {
                        final details = result.value!;
                        navigator.pushNamed(
                          AppRoutes.srpPersonDetails,
                          arguments: PersonDataArgs(person: details),
                        );
                      } else {
                        final msg = result.isErr
                                      ? result.error.message
                                      : 'Nie udało się pobrać szczegółów osoby.';
                        s.hideCurrentSnackBar();
                        s.showSnackBar(SnackBar(content: Text(msg)));
                      }
                    } catch (e) {
                      s.hideCurrentSnackBar();
                      s.showSnackBar(SnackBar(content: Text('Błąd: $e')));
                    }
                  },
                ),
                const SizedBox(height: 8),
                ArrowButton(
                  title: 'Dowód osobisty',
                  onTap: () {
                    final s = ScaffoldMessenger.of(context);
                    s.hideCurrentSnackBar();
                    s.showSnackBar(
                      SnackBar(content: Text('Dowód osobisty: ${shortPersonLabel()}')),
                    );
                                      
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // --- Dół panelu: klawisz WYBIERZ ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton.icon(
              onPressed: () {
                final s = ScaffoldMessenger.of(context);
                s.hideCurrentSnackBar();
                s.showSnackBar(
                  SnackBar(content: Text('Wybrano: ${shortPersonLabel()}')),
                );
                // Jeśli chcesz zamknąć widok z wynikiem:
                // Navigator.of(context).pop(person);
              },
              icon: const Icon(Icons.check),
              label: const Text('Wybierz'),
            ),
          ),
        ],
      ),
    );
  }





}
