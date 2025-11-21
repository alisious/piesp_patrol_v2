import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart';


class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scope = AppScope.of(context);
    final authController = scope.authController as AuthController;
    
    // Sprawdź rolę użytkownika tylko raz (profil nie zmienia się po zalogowaniu)
    final hasSupervisorRole = _hasSupervisorRole(authController);

    // === Ograniczenie szerokości na web ===
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sekcja: Służba (tylko dla Supervisora)
          if (hasSupervisorRole) ...[
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
              title: 'Dodaj służbę doraźną',
              onTap: () {
                // TODO: Nawigacja do strony dodawania służby doraźnej - zostanie dodana później
              },
            ),
            const SizedBox(height: 24),
          ],

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
            title: 'Sprawdź osobę', 
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.srpPersonsSearch),
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Czy posiada broń prywatną?',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.zwCheckWeaponHolderPage,
            ),
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Czy może być tam broń?',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.zwCheckWeaponAddressPage,
            ),
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Czy jest żołnierzem?',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.zwCheckSoldierPage,
            ),
          ),

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
         
          ArrowButton(
            title: 'Sprawdź pojazd', 
            onTap: ( )=> Navigator.pushNamed(
              context,
              AppRoutes.vehicleQuestionExtendedPage
              ),
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Sprawdź pojazd wojskowy', 
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.wpmSearch
              ),
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Sprawdź uprawnienia kierowcy',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.upkiCheckPage,
            ),
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Sprawdź wykroczenia',
            onTap: () {
              final auth = AppScope.of(context).authController as AuthController;
              if (auth.meProfile?.ksipUserId == null || 
                  auth.meProfile!.ksipUserId!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nie masz uprawnień do sprawdzania osób w KSIP! Skontaktuj się z przełożonym.',
                    ),
                  ),
                );
                return;
              }
              Navigator.pushNamed(
                context,
                AppRoutes.ksipCheckPersonPage,
              );
            },
          ),
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Zarejestruj MRD5',
            onTap: () {
              final auth = AppScope.of(context).authController as AuthController;
              if (auth.meProfile?.ksipUserId == null || 
                  auth.meProfile!.ksipUserId!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nie masz uprawnień do rejestracji karty MRD5 w KSIP! Skontaktuj się z przełożonym.',
                    ),
                  ),
                );
                return;
              }
              // TODO: Nawigacja do strony rejestracji MRD5 - zostanie dodana później
            },
          ),

          const SizedBox(height: 24),
         
        ],
      ),
    ),
      ),
    );
  }

  /// Sprawdza czy użytkownik ma rolę Supervisor (role = 1)
  bool _hasSupervisorRole(AuthController authController) {
    final meProfile = authController.meProfile;
    if (meProfile == null) return false;
    
    // Sprawdź czy użytkownik ma którąkolwiek rolę z role = 1 (Supervisor)
    return meProfile.roles.any((role) => role.role == 1);
  }
}
