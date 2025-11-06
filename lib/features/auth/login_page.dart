import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// dopasuj ścieżki importów do swoich plików:
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.auth,
    required this.config,
  });

  final AuthController auth;
  final ApiConfig config;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _badgeCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.login(
        _badgeCtrl.text.trim(),
        _pinCtrl.text.trim(),
      );
      if (!mounted) return;
      // nawigacja po sukcesie – jeśli masz route na stronę główną:
      Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
         title: const Text(''),
         automaticallyImplyLeading: false, //nie rysuj strzałki na loginie
         actions: [
          IconButton(
            tooltip: 'Ustawienia',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settingsPage),
          ),
        ],
      ),
      body: SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO
              Hero(
                tag: 'piespLogo',
                child: Image.asset(
                  'assets/images/piesp_logo.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 16),

              // 🔒 BLOK FORMULARZA – STAŁA, ROZSĄDNA SZEROKOŚĆ
              Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Numer odznaki
                      TextFormField(
                        controller: _badgeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Numer odznaki',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: UnderlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Podaj numer odznaki' : null,
                      ),
                      const SizedBox(height: 8),

                    // PIN
                    TextFormField(
                      controller: _pinCtrl,
                      decoration: const InputDecoration(
                        labelText: 'PIN',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: UnderlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Podaj PIN' : null,
                    ),
                    const SizedBox(height: 16),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                      ),

                    // Zaloguj
                    FilledButton.icon(
                      icon: _busy
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(_busy ? 'Logowanie…' : 'Zaloguj'),
                      onPressed: _busy ? null : _doLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // API (jeśli zostawiłeś)
                    Text(
                      'API: ${widget.config.baseUrl}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),

                    // Reset PIN tuż pod API
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/reset-pin'),
                        child: const Text('Reset PIN'),
                      ),
                    ),
                  ],
                ),
              ),
          )],
          ),
        ),
      );
    },
  ),
),

      );
  }
}
