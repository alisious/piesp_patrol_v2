// lib/features/vehicles/pages/wpm_search_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart';

/// Strona wyników WPM.
/// UWAGA: Wyświetlaj tę stronę WYŁĄCZNIE po pozytywnym wyniku zapytania
/// (HTTP 200 oraz pole "status" == 0). Błędy/komunikaty obsłuż na stronie wyszukiwania.
class WpmSearchResultPage extends StatelessWidget {
  const WpmSearchResultPage({
    super.key,
    required this.rows,
  });

  /// Lista zwróconych pojazdów (już po walidacji: http=200, status=0).
  final List<WpmVehicleDto> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Znalezione pojazdy: ${rows.length}'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.surfaceTint,
      ),
      body: rows.isEmpty
          ? _EmptyState(color: cs.onSurfaceVariant)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = rows[index];
                return _VehicleCard(dto: d);
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Brak wyników.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.dto});
  final WpmVehicleDto dto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Subtelne tło karty – bez withOpacity, zgodnie z preferencją:
    final cardColor = cs.surfaceContainerHighest;
    final divider = Divider(
      height: 16,
      thickness: 1,
      color: cs.outlineVariant,
    );

    final lines = _kvList(dto);

    return Card(
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nagłówek z nr rej. lub VIN (jeśli brak nr rej.)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dto.nrRejestracyjny?.trim().isNotEmpty == true
                    ? dto.nrRejestracyjny!.trim()
                    : (dto.numerPodwozia?.trim().isNotEmpty == true
                        ? dto.numerPodwozia!.trim()
                        : 'Pojazd'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            divider,
            const SizedBox(height: 8),

            // Parametry klucz-wartość (tylko te != null/niepuste)
            ...lines.map((kv) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _KvLine(label: kv.$1, value: kv.$2),
                )),
          ],
        ),
      ),
    );
  }

  /// Buduje listę (etykieta, wartość) wyłącznie z pól niepustych.
  List<(String, String)> _kvList(WpmVehicleDto d) {
    final res = <(String, String)>[];

    void add(String label, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) res.add((label, v));
    }

    void addInt(String label, int? value) {
      if (value != null) res.add((label, value.toString()));
    }

    // Spec z projektu: pokazywać wszystkie atrybuty jeśli różne od null.
    // Zachowujemy czytelny porządek pól.
    add('Opis', d.opis);
    addInt('Rok produkcji', d.rokProdukcji);
    add('Numer podwozia (VIN)', d.numerPodwozia);
    add('Nr ser. producenta', d.nrSerProducenta);
    add('Nr ser. silnika', d.nrSerSilnika);
    add('Miejscowość', d.miejscowosc);
    add('Jednostka wojskowa', d.jednostkaWojskowa);
    add('Jednostka gospodarcza', d.jednostkaGospodarcza);
    add('Data aktualizacji', d.dataAktualizacji);

    // UWAGA: nr rejestracyjny pokazujemy w nagłówku karty,
    // jeśli chcesz również w treści, odkomentuj poniższą linię:
    // add('Nr rejestracyjny', d.nrRejestracyjny);

    return res;
  }
}

class _KvLine extends StatelessWidget {
  const _KvLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // value
        Expanded(
          flex: 7,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
