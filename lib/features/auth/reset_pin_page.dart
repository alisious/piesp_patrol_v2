import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/common_params.dart';

class ResetPinPage extends StatefulWidget {
  const ResetPinPage({super.key});

  @override
  State<ResetPinPage> createState() => _ResetPinPageState();
}

class _ResetPinPageState extends State<ResetPinPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _securityCodeCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _securityCodeCtrl.dispose();
    super.dispose();
  }

  String? _validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Podaj PIN';
    }
    if (value.length < 4) {
      return 'PIN musi mieć co najmniej 4 cyfry';
    }
    return null;
  }

  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Potwierdź PIN';
    }
    if (value != _newPinCtrl.text) {
      return 'PINy nie są zgodne';
    }
    return null;
  }

  String? _validateSecurityCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Podaj kod bezpieczeństwa';
    }
    return null;
  }

  Future<void> _doReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // TODO: Implementacja resetu PIN
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN został zresetowany')),
      );
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
        title: const Text('Reset PIN'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nowy PIN
                        TextFormField(
                          controller: _newPinCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nowy PIN',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: UnderlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: _validatePin,
                        ),
                        const SizedBox(height: 8),

                        // Potwierdź PIN
                        TextFormField(
                          controller: _confirmPinCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Potwierdź PIN',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: UnderlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: _validateConfirmPin,
                        ),
                        const SizedBox(height: 8),

                        // Kod bezpieczeństwa
                        InputBox(
                          controller: _securityCodeCtrl,
                          label: 'Kod bezpieczeństwa',
                          preset: InputPreset.text,
                          borderStyle: InputBorderStyle.underline,
                          prefixIcon: Icons.security,
                          textInputAction: TextInputAction.done,
                          validator: _validateSecurityCode,
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

                        // Zatwierdź
                        FilledButton.icon(
                          icon: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: Text(_busy ? 'Przetwarzanie…' : 'Zatwierdź'),
                          onPressed: _busy ? null : _doReset,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

