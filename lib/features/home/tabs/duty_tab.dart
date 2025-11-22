import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/duty/data/duty_api.dart';
import 'package:piesp_patrol/features/duty/data/duty_controller.dart';
import 'package:piesp_patrol/features/duty/data/duty_dtos.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart';

class DutyTab extends StatelessWidget {
  const DutyTab({super.key, this.unitName});
  final String? unitName;

  @override
 Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final services = AppScope.read(context);
    final dutyController = services.dutyController as DutyController;
    final authController = services.authController as AuthController;
    
    // Sprawdź rolę użytkownika tylko raz (profil nie zmienia się po zalogowaniu)
    final hasSupervisorRole = _hasSupervisorRole(authController);

    return AnimatedBuilder(
      animation: dutyController,
      builder: (context, _) {
        final hasCurrentDuty = dutyController.hasCurrentDuty;

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
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.hideCurrentSnackBar();
                final scope = AppScope.read(context);
                final dutyApi = scope.dutyApi as DutyApi;

                try {
                  final response = await dutyApi.getMyPlannedDuties();
                  if (!context.mounted) return;

                  final status = response.status ?? -1;
                  if (status != 0) {
                    final message = (response.message?.isNotEmpty ?? false)
                        ? response.message!
                        : 'Nie udało się pobrać służb.';
                    messenger.showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                    return;
                  }

                  final duties = response.data ?? const <DutyDto>[];
                  Navigator.of(context).pushNamed(
                    AppRoutes.myDutiesResultPage,
                    arguments: MyDutiesResultArgs(duties: duties),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Błąd podczas pobierania służb: $e'),
                    ),
                  );
                }
              },
              enabled: !hasCurrentDuty,
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Zakończ służbę',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.currentDutyPage);
              },
              enabled: hasCurrentDuty,
            ),
            // Klawisz "Dodaj służbę doraźną" tylko dla Supervisora
            if (hasSupervisorRole) ...[
              const SizedBox(height: 12),
              ArrowButton(
                title: 'Dodaj służbę doraźną',
                onTap: () {
                  // TODO: Nawigacja do strony dodawania służby doraźnej - zostanie dodana później
                },
                enabled: true,
              ),
            ],

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
              enabled: false,
            ),
            const SizedBox(height: 12),
            ArrowButton(
              title: 'Zakończ czynność',
              onTap: () {},
              enabled: false,
            ),
              ],
            ),
          ),
        );
      },
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
