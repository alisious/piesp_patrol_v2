import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key, required this.baseUrl});
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // === Ograniczenie szerokości na web ===
    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxContentWidth: 880,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sekcja 1: Osoby (z ikoną osoby)
          Row(
            children: [
              Icon(Icons.person, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                'Osoby',
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
            title: 'Szukaj osoby', 
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.srpPersonsSearch),
          ),
          const SizedBox(height: 12),
          ArrowButton(title: 'Dane osoby', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(title: 'Dowód osobisty', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(title: 'Czy żołnierz?', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(title: 'Czy osoba poszukiwana?', onTap: () {}),

          const SizedBox(height: 24),

          // Sekcja 2: Kierowca i pojazdy (z ikoną samochodu)
          Row(
            children: [
              Icon(Icons.directions_car, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                'Kierowca i pojazd',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ArrowButton(title: 'Szukaj pojazdu', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(title: 'Sprawdź pojazd', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Sprawdź pojazd wojskowy', 
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.wpmSearch
              ),
          ),
          const SizedBox(height: 12),
          ArrowButton(title: 'Sprawdź uprawnienia kierowcy', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(title: 'Sprawdź wykroczenia', onTap: () {}),
          const SizedBox(height: 12),
          ArrowButton(title: 'Zarejestruj MRD5', onTap: () {}),

          const SizedBox(height: 24),

          // Informacyjnie
          Text(
            'API: $baseUrl',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}
