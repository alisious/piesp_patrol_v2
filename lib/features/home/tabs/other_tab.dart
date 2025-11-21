import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/cep/data/cep_dictionary_service.dart';
import 'package:piesp_patrol/features/supervisor/data/supervisor_api.dart';
import 'package:piesp_patrol/features/supervisor/data/supervisor_dtos.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/widgets/arrow_button.dart'; // ← nowy import


class OtherTab extends StatefulWidget {
  const OtherTab({
    super.key,
    
   
  });

 

  @override
  State<OtherTab> createState() => _OtherTabState();
}

class _OtherTabState extends State<OtherTab> {
 
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final authController = scope.authController as AuthController;
    
    // Sprawdź rolę użytkownika tylko raz (profil nie zmienia się po zalogowaniu)
    final hasSupervisorRole = _hasSupervisorRole(authController);

    // Lista opcji
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ArrowButton(
          title: 'Ustawienia',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settingsPage),
        ),
        const SizedBox(height: 12),
         ArrowButton(
          title: 'CEP - Aktualizuj słowniki',
          onTap: () => updateCepDictionaries(context),
        ),
        // Wyświetl klawisz "Wygeneruj kod bezpieczeństwa" tylko dla Supervisora (role = 1)
        if (hasSupervisorRole) ...[
          const SizedBox(height: 12),
          ArrowButton(
            title: 'Wygeneruj kod bezpieczeństwa',
            onTap: () => generateSecurityCode(context),
          ),
        ],
        const SizedBox(height: 12),
        ArrowButton(
          title: 'Wyloguj',
          onTap: () async {
            final navigator = Navigator.of(context);// bezpiecznie przed await
            //await widget.onLogout();
            if (!mounted) return;
            navigator.pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            ); 
          },
        ),
      ],
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

Future<void> updateCepDictionaries(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context); // bezpiecznie przed await
  try {
    // Używamy read() aby uniknąć niepotrzebnych rebuildu
    final scope = AppScope.read(context);
    final service = scope.cepDictionaryService as CepDictionaryService;

    final res = await service.refreshVehicleDocumentTypes();

    final text = (res.status == 0)
        ? (res.message ?? 'Zaktualizowano słowniki CEP.')
        : (res.message ?? 'Błąd aktualizacji słowników CEP.');

    messenger.showSnackBar(SnackBar(content: Text(text)));
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Błąd aktualizacji słowników CEP.')),
    );
  }
}

Future<void> generateSecurityCode(BuildContext context) async {
  final scope = AppScope.read(context);

  final badgeNumberCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Wygeneruj kod bezpieczeństwa'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: TextFormField(
            controller: badgeNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Numer odznaki',
              hintText: 'Wprowadź numer odznaki',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Podaj numer odznaki';
              }
              if (value.length < 4) {
                return 'Numer odznaki musi mieć co najmniej 4 cyfry';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Anuluj'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(dialogContext).pop(badgeNumberCtrl.text.trim());
            }
          },
          child: const Text('Generuj'),
        ),
      ],
    ),
  );

  if (result == null || result.isEmpty) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  try {
    final supervisorApi = scope.supervisorApi as SupervisorApi;
    final request = SupervisorGenerateCodeRequestDto(badgeNumber: result);
    final response = await supervisorApi.generateCode(request);

    if (!context.mounted) return;

    final code = response.securityCode;
    if (code == null || code.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Błąd: nie otrzymano kodu bezpieczeństwa.')),
      );
      return;
    }

    // Wyświetl kod w dialogu - dialog nie zamyka się automatycznie
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog nie zamknie się po kliknięciu poza nim
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kod bezpieczeństwa'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SelectableText(
            code,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  fontSize: 32,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Błąd generowania kodu: ${e.toString().replaceAll('SupervisorApiException: ', '')}'),
      ),
    );
  } finally {
    badgeNumberCtrl.dispose();
  }
}
