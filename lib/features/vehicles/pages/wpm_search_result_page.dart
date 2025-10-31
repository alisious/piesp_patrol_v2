// lib/features/vehicles/pages/wpm_search_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

/// Strona wyników WPM – wyświetlaj ją wyłącznie po sukcesie (HTTP 200 i status == 0).
class WpmSearchResultPage extends StatelessWidget {
  const WpmSearchResultPage({
    super.key,
    required this.rows,
  });

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
      // Bez SingleChildScrollView — ListView ma własny scroll
      body: ResponsiveCenter(
        maxContentWidth: 1024, // ograniczenie szerokości dla WEB
        padding: const EdgeInsets.all(16),
        child: rows.isEmpty
            ? _EmptyState(color: cs.onSurfaceVariant)
            : ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final d = rows[index];
                  return _VehicleCard(dto: d);
                },
              ),
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

    final title = (dto.nrRejestracyjny ?? '').trim().isNotEmpty
        ? dto.nrRejestracyjny!.trim()
        : ((dto.numerPodwozia ?? '').trim().isNotEmpty
            ? dto.numerPodwozia!.trim()
            : 'Pojazd');

    final lines = _kvList(dto);

    return Card(
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(lines.length, (i) {
              final kv = lines[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i == lines.length - 1 ? 0 : 6),
                child: _KvLine(label: kv.$1, value: kv.$2),
              );
            }),
          ],
        ),
      ),
    );
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
        SizedBox(
          width: 220,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
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

// Zbierz pary KVP z filtrowaniem null/pustych i zachowaniem kolejności
List<(String, String)> _kvList(WpmVehicleDto d) {
  final res = <(String, String)>[];

  void add(String label, String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return;
    res.add((label, s));
  }

  void addInt(String label, int? v) {
    if (v == null) return;
    res.add((label, '$v'));
  }

  // Pokazuj wszystkie atrybuty jeśli różne od null:
  add('Opis', d.opis);
  addInt('Rok produkcji', d.rokProdukcji);
  add('Numer podwozia (VIN)', d.numerPodwozia);
  add('Nr ser. producenta', d.nrSerProducenta);
  add('Nr ser. silnika', d.nrSerSilnika);
  add('Miejscowość', d.miejscowosc);
  add('Jednostka wojskowa', d.jednostkaWojskowa);
  add('Jednostka gospodarcza', d.jednostkaGospodarcza);
  add('Data aktualizacji', d.dataAktualizacji);
  // Nr rejestracyjny jest w tytule; jeśli chcesz również w treści:
  // add('Nr rejestracyjny', d.nrRejestracyjny);

  return res;
}
