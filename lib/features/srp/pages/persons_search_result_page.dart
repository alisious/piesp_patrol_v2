import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/srp/data/srp_api.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart';
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart';

/// Strona wyników wyszukiwania osób.
/// Oczekuje listy wyników przekazanej przez konstruktor.
class PersonsSearchResultPage extends StatelessWidget {
  const PersonsSearchResultPage({
    super.key,
    required this.results,
  });

  final List<OsobaZnalezionaDto> results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyniki wyszukiwania osób'),
      ),
      body: results.isEmpty
          ? Center(
              child: Text(
                'Brak wyników.',
                style: theme.textTheme.titleMedium?.copyWith(color: cs.outline),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _PersonCard(person: results[i]),
            ),
    );
  }
}

class _PersonCard extends StatefulWidget {
  const _PersonCard({required this.person});

  final OsobaZnalezionaDto person;

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  Uint8List? _decodeBase64Image(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Obsługa "data:image/...;base64,..."
    final base64Part =
        s.startsWith('data:image') ? (s.split(',').length > 1 ? s.split(',').last : '') : s;
    if (base64Part.isEmpty) return null;

    try {
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkWantedAndNotify(BuildContext context) async {
  final ctx = context; // kopiujemy kontekst przed async gap
  final messenger = ScaffoldMessenger.of(ctx);
  messenger.hideCurrentSnackBar();

  final pesel = (widget.person.pesel ?? '').trim();
  if (pesel.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Brak numeru PESEL dla tej osoby.')),
    );
    return;
  }

  // Pobierz zależności PRZED await
  final scope = AppScope.of(ctx);
  final srpApi = scope.srpApi as SrpApi;

  try {
    final result = await srpApi.checkIfWanted(pesel: pesel);

    // Strzeż użycie kontekstu po async gap
    if (!ctx.mounted) return;

    if (result.isOk) {
      final isWanted = result.value;

      setState(() {
        widget.person.czyPoszukiwana = isWanted;
      });

      if (isWanted) {
        // Czerwony, migający splash — "OSOBA POSZUKIWANA!"
        showGeneralDialog(
          context: ctx,
          barrierDismissible: true,
          barrierLabel: 'wanted',
          pageBuilder: (_, __, ___) => const _WantedSplash(),
          transitionBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 200),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Brak wpisów o poszukiwaniu.')),
        );
      }
    } else {
      final errMsg = (result.error.message.isNotEmpty)
          ? result.error.message
          : 'Błąd podczas sprawdzania poszukiwania.';
      messenger.showSnackBar(SnackBar(content: Text(errMsg)));
    }
  } catch (e) {
    if (!ctx.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('Wyjątek: $e')));
  }
}

  Future<void> _openPersonId(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final pesel = (widget.person.pesel ?? '').trim();
    if (pesel.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Brak numeru PESEL dla tej osoby.')),
      );
      return;
    }

    // Pobierz zależności przed async gap
    final scope = AppScope.of(context);
    final srpApi = scope.srpApi as SrpApi;
    final navigator = Navigator.of(context);

    try {
      final proxy = await srpApi.getCurrentPersonIdByPesel(pesel: pesel);
            
      if (!mounted) return;

      if ((proxy.status ?? -1) != 0) {
        final msg = (proxy.message?.isNotEmpty ?? false)
            ? proxy.message!
            : 'Nie udało się pobrać danych dowodu.';
        messenger.showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      // Nawigacja na stronę wyników dowodu osobistego — zachowujemy trasę z pliku.
      if (proxy.data?.dowod != null)
      { 
        navigator.pushNamed(
        AppRoutes.srpPersonId,
        arguments: PersonIdArgs(dowod: proxy.data!.dowod!),
      );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Wyjątek: $e')));
    }
  }

  void _openPersonDetails(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final pesel = (widget.person.pesel ?? '').trim();
    if (pesel.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Brak numeru PESEL dla tej osoby.')),
      );
      return;
    }

    // Pobierz zależności przed async gap
    final scope = AppScope.of(context);
    final srpApi = scope.srpApi as SrpApi;
    final navigator = Navigator.of(context);
    
     try {
                        final result = await srpApi.getPersonByPesel(
                        request: GetPersonByPeselRequestDto(pesel: pesel),
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
                        messenger.showSnackBar(SnackBar(content: Text(msg)));
                      }
                    } catch (e) {
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(SnackBar(content: Text('Błąd: $e')));
                    }
   }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bytes = _decodeBase64Image(widget.person.zdjecie);

 final subtitleLines = <String>[
      if ((widget.person.pesel ?? '').isNotEmpty) 'PESEL: ${widget.person.pesel}',
      if ((widget.person.dataUrodzenia ?? '').isNotEmpty)
        'Data ur.: ${widget.person.dataUrodzenia}',
      if ((widget.person.miejsceUrodzenia ?? '').isNotEmpty)
        'Miejsce ur.: ${widget.person.miejsceUrodzenia}',
      if ((widget.person.plec ?? '').isNotEmpty) 'Płeć: ${widget.person.plec}',
      if (widget.person.czyZyje != null) 'Czy żyje: ${widget.person.czyZyje! ? 'TAK' : 'NIE'}',
      if (widget.person.czyPeselAnulowany != null)
        'PESEL anulowany: ${widget.person.czyPeselAnulowany! ? 'TAK' : 'NIE'}',
      if ((widget.person.seriaINumerDowodu ?? '').isNotEmpty)
        'Dowód: ${widget.person.seriaINumerDowodu}',
     
    ];

    String buildTitle() {
      if ((widget.person.nazwisko ?? '').isNotEmpty ||
          (widget.person.imiePierwsze ?? '').isNotEmpty) {
        final imiona = [
          widget.person.imiePierwsze,
          widget.person.imieDrugie,
        ].where((e) => (e ?? '').isNotEmpty).join(' ');
        return [imiona, widget.person.nazwisko]
            .where((e) => (e ?? '').isNotEmpty)
            .join(' ')
            .trim();
      }
      
      return 'Osoba';
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bytes != null)
            Image.memory(
              bytes,
              fit: BoxFit.fitHeight,
              height: 300,
            ),
            if (widget.person.czyPoszukiwana)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '⚠️ Osoba poszukiwana',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  buildTitle(),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(subtitleLines.join('\n'),
                    style: theme.textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),

                // ——— Szczegóły osoby (zachowujemy nawigację do srpPersonDetails) ———
                ArrowButton(
                  title: 'Szczegóły osoby',
                  onTap: () => _openPersonDetails(context),
                ),
                const SizedBox(height: 8),
                         
                // ——— Dowód osobisty (zachowujemy nawigację do srpPersonId) ———
                ArrowButton(
                  title: 'Dowód osobisty',
                  onTap: () => _openPersonId(context),
                ),
                const SizedBox(height: 8),
                // ——— Czy osoba poszukiwana? ———
                ArrowButton(
                  title: 'Czy osoba poszukiwana?',
                  onTap: () => _checkWantedAndNotify(context),
                ),
                const SizedBox(height: 8),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Migający, pełnoekranowy splash "OSOBA POSZUKIWANA!".
/// UWAGA: nie używamy Color.withOpacity(...); miganie realizuje AnimatedBuilder + Opacity.
class _WantedSplash extends StatefulWidget {
  const _WantedSplash();

  @override
  State<_WantedSplash> createState() => _WantedSplashState();
}

class _WantedSplashState extends State<_WantedSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);

    // Auto-zamknięcie po 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red, // pełny czerwony ekran
      child: Center(
        child: AnimatedBuilder(
          animation: _opacity,
          builder: (context, _) {
            return Opacity(
              opacity: _opacity.value,
              child: Text(
                'OSOBA POSZUKIWANA!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
