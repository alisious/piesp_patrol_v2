import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/cep/data/cep_dictionary_service.dart';
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
}

Future<void> updateCepDictionaries(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context); // bezpiecznie przed await
  try {
    final scope = AppScope.of(context);
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
