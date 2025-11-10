import 'package:flutter/material.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart';

class DutyTab extends StatelessWidget {
  const DutyTab({super.key, this.unitName});
  final String? unitName;

  @override
 Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sekcja 1: Służba
            Row(
              children: [
                Icon(Icons.shield_moon, color: cs.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Służba',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Rozpocznij służbę',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Zakończ służbę',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Dodaj służbę doraźną',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Sekcja 2: Czynności
            Row(
              children: [
                Icon(Icons.checklist, color: cs.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Czynności',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Rozpocznij czynność',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Zakończ czynność',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
